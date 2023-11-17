"""
Author: Marcus Hallberg
Email: marcus.oj.hallberg@gmail.com

BEFORE RUNNING:
---------------
1. If not already done, enable the Compute Engine API
   and check the quota for your project at
   https://console.developers.google.com/apis/api/compute
2. This sample uses Application Default Credentials for authentication.
   If not already done, install the gcloud CLI from
   https://cloud.google.com/sdk and run
   `gcloud beta auth application-default login`.
   For more information, see
   https://developers.google.com/identity/protocols/application-default-credentials
3. Install the Python client library for Google APIs by running
   `pip install --upgrade google-api-python-client`
    pip install --upgrade google-cloud-storage
"""
import argparse
import base64
import datetime
import json
import time
from datetime import datetime, timedelta
from tempfile import NamedTemporaryFile

import google.auth
import google.auth.transport.requests
import kubernetes
from google.auth.exceptions import TransportError
from google.auth.transport import requests
from google.cloud import container, storage
from kubernetes.client.exceptions import ApiException, ApiValueError
from kubernetes.stream import stream


########################################################################################################################
def get_credentials(project_id: str):
    # Start authentication - with subprocess modification to allow for re-enabling the project creds.
    # Source: https://stackoverflow.com/questions/37489477/how-to-use-google-cloud-client-library-for-python-to-configure-the-gcloud-projec
    # https://google-auth.readthedocs.io/en/stable/reference/google.oauth2.credentials.html
    import subprocess

    subprocess.run(
        [
            "gcloud",
            "config",
            "set",
            "project",
            project_id,
        ]
    )
    credentials, project_id = google.auth.default()
    credentials.refresh(requests.Request())
    return credentials


########################################################################################################################
def generate_signed_url(
    target_project: str,
    bucket_name: str,
    blob_object_name: str,
    cred,
    sa_acc_to_imp: str,
    content_type="application/octet-stream",
):
    response = {}
    response["status"] = "not_ready"

    # Create storage resources
    storage_client = storage.Client(project=target_project)
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(blob_object_name)
    try:
        url = blob.generate_signed_url(
            service_account_email=sa_acc_to_imp,
            access_token=cred.token,
            version="v4",
            expiration=datetime.now() + timedelta(hours=6),
            method="PUT",
            content_type=content_type,
        )
        response["result"] = url
        response["status"] = "done"
    except TransportError as e:
        if "error" in str(e):
            response["error"] = str(e)
        else:
            raise
    return response


########################################################################################################################
def kube_client(
    cred_gke: google.auth.credentials, cluster_id: str, project_id: str, zone: str
):
    response = {}
    response["status"] = "not_ready"
    container_client = google.cloud.container.ClusterManagerClient(credentials=cred_gke)
    request = {"name": f"projects/{project_id}/locations/{zone}/clusters/{cluster_id}"}
    resp = container_client.get_cluster(request=request)
    configuration = kubernetes.client.Configuration()
    configuration.host = f"https://{resp.endpoint}:443"

    with NamedTemporaryFile(delete=False) as ca_cert:
        ca_cert.write(base64.b64decode(resp.master_auth.cluster_ca_certificate))
        configuration.ssl_ca_cert = ca_cert.name

    configuration.api_key_prefix["authorization"] = "Bearer"
    configuration.api_key["authorization"] = cred_gke.token
    kube_client = kubernetes.client.CoreV1Api(
        kubernetes.client.ApiClient(configuration)
    )
    return kube_client


#########################################################################################################################
def define_kubectl_commands(
    blob_object_name,
    presigned_url: str,
    attacker_script_file: str,
    bucket: str,
    volatility_script: str,
    zone: str,
    gke_node: str,
):
    avml_file_path = str("/avml/" + blob_object_name)
    output_folder = blob_object_name.replace(".lime.compressed", "")
    avml_commands = [
        # Doing memory dump with AVML
        ["/bin/bash", "-c", "pwd"],
        [
            "/bin/bash",
            "-c",
            "/avml/target/x86_64-unknown-linux-musl/release/avml --compress --source /proc/kcore "
            + avml_file_path,
        ],
        ["/bin/bash", "-c", "ls /avml"],
        # Uploading to cloud storage
        [
            "/bin/bash",
            "-c",
            "curl -X PUT -H 'Content-Type: application/octet-stream' --upload-file "
            + avml_file_path
            + " '{}'".format(presigned_url),
        ],
    ]

    attacker_commands = [
        [
            "/bin/bash",
            "-c",
            "python3 " + attacker_script_file + " > /dev/null 2> /dev/null &",
        ]
    ]
    # Add download commands from bucket
    gcloud_command = (
        "$(gcloud compute disks describe "
        + gke_node
        + " --zone="
        + zone
        + " | grep image | grep sourceImage | awk -F / '{ print $(NF-0) }' | sed -e 's/.*cos-[^-]*-\(.*\)-.*[a-z]-.*[a-z]/\\1/'| tr - .)"
    )
    instace_commands = [
        "pwd",
        "ls -la",
        "gsutil cp gs://" + bucket + "/" + blob_object_name + " " + blob_object_name,
        "./avml/target/x86_64-unknown-linux-musl/release/avml-convert "
        + blob_object_name
        + " "
        + blob_object_name.replace(".compressed", ""),
        "mkdir " + output_folder,
        "curl -O https://storage.googleapis.com/cos-tools/"
        + gcloud_command
        + "/vmlinux",
        "./dwarf2json/dwarf2json linux --elf vmlinux > volatility3/volatility3/symbols/dwarf2json_profile.json",
        "./" + volatility_script + " " + output_folder + " " + " 2> /dev/null",
        # "rm *.lime *.lime.compressed",
        # "rm vmlinux",
    ]
    return instace_commands, avml_commands, attacker_commands


#########################################################################################################################
def memdump_container_run_cmd(exec_command_array, pod_name, pod_namespace, v1):
    # Docs: https://askubuntu.com/questions/141928/what-is-the-difference-between-bin-sh-and-bin-bash
    response = {}

    for exec_command in exec_command_array:
        print("\n" + f"Current kubectl command is: {exec_command}")
        try:
            result = stream(
                v1.connect_get_namespaced_pod_exec,
                pod_name,
                pod_namespace,
                command=exec_command,
                stderr=True,
                stdin=False,
                stdout=True,
                tty=False,
            )
            response[str(exec_command)] = {}
            response[str(exec_command)]["status"] = "Done"
            response[str(exec_command)]["result"] = result

        except ApiException as e:
            print(f"error for: {exec_command}" + "\n" + "was: " + str(e))
            response[str(exec_command)]["status"] = "Failed"
    return response


########################################################################################################################
def avml_instance_actions(
    cred, instance_name, project_id, zone, blob_object_name, instace_commands
):
    response = {}

    import subprocess

    for instance_command in instace_commands:
        try:
            print("\n" + f"Current avml instance command is: {instance_command}")
            result = subprocess.run(
                [
                    "gcloud",
                    "compute",
                    "ssh",
                    "--project=" + project_id,
                    "--zone=" + zone,
                    instance_name,
                    "--tunnel-through-iap",
                    "--command=" + instance_command,
                ]
            )
            response[str(instance_command)] = {}
            response[str(instance_command)]["status"] = "Done"
            response[str(instance_command)]["result"] = result
        except ApiException as e:
            print(f"error for: {instance_command}" + "\n" + "was: " + str(e))
            response[str(instance_command)]["status"] = "Failed"

    return response


########################################################################################################################
def get_gcp_environment(terraform_file_name: str):
    import os
    import re

    cwd = os.getcwd()
    response = {}

    try:
        terraform_output = open(f"{cwd}/terraform/{terraform_file_name}")
        # Loop through each line via file handler
        for line in terraform_output:
            if line != "":
                variable = re.search("([^\s]+)", line)
                result = re.search("[^\s]*$", line)
                if variable != "" and result != "":
                    response[variable.group()] = result.group().strip('"')
    except FileNotFoundError as e:
        print(f"error was: {e}")
    return response


########################################################################################################################
if __name__ == "__main__":
    print("Starting")
    terraform_file_name = "terraform_resources.conf"
    gcp_setup = get_gcp_environment(terraform_file_name)

    # Setting variables
    try:
        project = gcp_setup["gcp_project"]
        instance_name = gcp_setup["gcp_instance"]
        zone = gcp_setup["zone"]
        bucket_name = gcp_setup["gcp_avml_bucket"]
        target_project = gcp_setup["gcp_project"]
        sa_acc_to_imp = gcp_setup["gcp_instance_avml_sa"]
        volatility_script = gcp_setup["volatility_script"]
        cluster_id = gcp_setup["gke_cluster_name"]
        pod_name_avml = gcp_setup["pod_name_avml"]  #'pod-node-affinity-mem-dump'
        pod_namespace_avml = gcp_setup["pod_namespace_avml"]
        pod_name_att = gcp_setup["pod_name_att"]  #'pod_node_affinity_attacker_pod'
        pod_namespace_att = gcp_setup["pod_namespace_att"]  #'default'
    except KeyError as e:
        print(f"error was: {e}")
    blob_object_name = (
        "output_" + datetime.today().strftime("%Y_%m_%d_%H_%M") + ".lime.compressed"
    )
    status = {}
    attacker_script_file = "cmds.py"  # Name of script inside attacker container. Don't modify this name unless modified in: ./PATH/image_files/attacker/scripts

    # Prepare parser
    parser = argparse.ArgumentParser(description="Process GKE node name.")
    # Define argument
    parser.add_argument("--gke_node_name", type=str, required=True)
    # Parse the argument
    gke_node = parser.parse_args().gke_node_name

    cred_target_proj = get_credentials(target_project)
    status["generate_signed_url"] = generate_signed_url(
        target_project, bucket_name, blob_object_name, cred_target_proj, sa_acc_to_imp
    )
    print("generate_signed_url status result:")
    print(json.dumps(status["generate_signed_url"], sort_keys=True, indent=4))
    print("\n")

    cred_gke = get_credentials(project)
    v1 = kube_client(cred_gke, cluster_id, project, zone)

    if status["generate_signed_url"]["status"] == "done" and "CoreV1Api" in str(
        type(v1)
    ):
        # Get commands
        instace_commands, avml_commands, attacker_commands = define_kubectl_commands(
            blob_object_name,
            status["generate_signed_url"]["result"],
            attacker_script_file,
            bucket_name,
            volatility_script,
            zone,
            gke_node,
        )

        status["memdump_container_run_cmd"] = {}

        try:
            print(f"Starting command execution for attacker")
            status["memdump_container_run_cmd"]["attacker"] = memdump_container_run_cmd(
                attacker_commands, pod_name_att, pod_namespace_att, v1
            )
            print(f"Stopped command execution for attacker" + "\n")

            time.sleep(10)

            print(f"Starting command execution for avml")
            status["memdump_container_run_cmd"]["avml"] = memdump_container_run_cmd(
                avml_commands, pod_name_avml, pod_namespace_avml, v1
            )
            print(f"Stopped command execution for avml")
            status["memdump_container_run_cmd"]["status"] = "done"
        except KeyError as e:
            print(f"Command sequence failed. Error was: {e}")
            status["memdump_container_run_cmd"]["status"] = "failed"
    print("Final status was")

    try:
        print(json.dumps(status, sort_keys=True, indent=4))
    except TypeError as e:
        print(status)

    cred_target_proj = get_credentials(target_project)

    if status["memdump_container_run_cmd"]["status"] == "done":
        print(f"Starting command execution for avml instance")
        status["memdump_container_run_cmd"]["avml_instance"] = avml_instance_actions(
            cred_target_proj,
            instance_name,
            target_project,
            zone,
            blob_object_name,
            instace_commands,
        )
        print(f"Stopped command execution for avml instance")
    print("Finished")
