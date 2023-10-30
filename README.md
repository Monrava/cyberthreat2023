[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# CyberThreat 2023 - Analyzing volatile memory on a Google Kubernetes Engine node
Demo setup for my presentation at SANS CyberThreat 2023 on volatile memory analysis in Google Kubernetes Engine (GKE).

## Table of Contents  
[Presentation video](##Presentation-video)

[Description](##Description)

[Configure GCP environment](##Configure-GCP-environment)

[Terraform](##Terraform)

[Access resources](##Access-resources)

[Start demo](##Start-demo)

[LICENSE](##LICENSE)

## Presentation video
[![Presentation video](https://pbs.twimg.com/media/F4yYRS-XQAAvds-?format=jpg&name=large)](https://www.sans.org/cyber-security-training-events/cyberthreat23/#:~:text=Analyzing%20Volatile%20Memory%20on%20a%20Google%20Kubernetes%20Engine%20Node)

## Description
This repository sets up a GKE cluster, forensic GCE, cloud storage bucket and associated IAM roles and permissions in a default GCP project.
You can then create an AVML container with the tools to conduct a memory dump and also an attacker container with a few demo scripts.

## Configure GCP environment
### Add IAM permissions 
Add the following permissions to your gcloud principle in your GCP project.
```  	
Project IAM Admin				
Service Account Admin
Service Account Token Creator
```
### Enable billing acccount
Check your CPU limitations based on the resources you want to create:
https://cloud.google.com/billing/docs/how-to/modify-project

### Install gcloud
Install gcloud using this link: https://cloud.google.com/sdk/docs/install

### Authenticate to GCP
```bash
$ gcloud auth application-default login
```

### Enable GCP project services
https://cloud.google.com/migrate/containers/docs/config-dev-env
```bash
$ gcloud services enable servicemanagement.googleapis.com servicecontrol.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com container.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com
```

### Activate GCP ssh key permissions: 
```bash
$ ssh-add ~/.ssh/google_compute_engine
```
### Create GCR images
```bash
$ export gcp_project=YOUR_GCP_PROJECT_NAME
$ export zone=ZONE

$ docker build -t gcr.io/$gcp_project/avml_image:latest -f image_files/avml/Dockerfile .

$ docker build -t gcr.io/$gcp_project/attacker_image:latest  -f image_files/attacker/Dockerfile .
```
### Push GCR images
```bash
$ docker push  gcr.io/$gcp_project/avml_image:latest  
$ docker push  gcr.io/$gcp_project/attacker_image:latest 
```
## Terraform
This sections explains how to setup your Terraform environment to create the needed resources.
### Install Terraform:
  https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
### Instantiate: 
```bash
$ terraform init
```

### Update environment:
Modify main.tf in ./cyberthreatnyc2023/terraform_cyberthreat to reflect your GCP environment.    
Variables to add: 
```bash
var.pid
var.installation_user
var.installation_path
```

### Create Terraform GKE cluster, resources and instance
```bash
$ cd ./cyberthreatnyc2023/terraform_cyberthreat
$ terraform apply -lock=true -auto-approve
$ terraform output  >> terraform_resources.conf
```

## Access resources
```bash
$ gcloud container clusters get-credentials demo-gke-cluster --zone $zone --project $gcp_project
$ kubectl exec --stdin --tty pod-node-affinity-demo-attacker-pod --namespace default -- /bin/bash  
```
Run:
```bash
$ ./actions.sh 
```
And other commands you want and then exit the shell.
When you log back in, you should see the bash history updated by typing:
```bash
$ history
```

## Start demo

### Create virtual environment and install dependencies
```bash
$ python3 -m venv .venv
$ source .venv/bin/activate
(.venv)$ pip3 install -r requirements.txt
```
### Run script
Execute the python script using the GKE node name. 
E.g.
```bash
$ python3 memory_collection.py --gke_node_name gke-demo-gke-clust-demo-gke-node--f72013e9-jm9c
```

### Access forensic compute engine
Once the script finishes, access the AVML instance here.
```bash
$ gcloud compute ssh "avml-instance" --tunnel-through-iap
```

## LICENSE
This project is licensed under the terms of the GNU General Public License v3.0