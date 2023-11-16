########################################################################
# Define modules
########################################################################
module "avml_resources" {
    source  = "./modules/create_avml_resources"
    pid = var.pid
    installation_user = var.module_avml_resources_installation_user
    installation_path = var.module_avml_resources_installation_path
    providers = {
      google = google.gcp
    }
}

module "gke_cluster" {
    source  = "./modules/create_cluster"
    pid = var.pid
    providers = {
      google = google.gcp
    }
}

module "gke_resources" {
    source  = "./modules/create_resources"
    pid = var.pid
    depends_on = [ module.gke_cluster ]
    providers = {
      google = google.gcp
      # Kubernetes config is needed to create pods and also relates to the cluster created in module "gke_cluster"
      kubernetes = kubernetes.kube_config
    }
}
########################################################################
# Define providers
########################################################################
data "google_client_config" "default" {}

provider "google" {
  alias   = "gcp"
  project = var.pid
  region  = var.region
  zone    = var.zone
}

provider "kubernetes" {
  alias = "kube_config"
  host                      = module.gke_cluster.kubernetes_host
  token                     = data.google_client_config.default.access_token
  cluster_ca_certificate    = module.gke_cluster.kubernetes_cluster_ca_certificate
}
########################################################################
# Define variables
########################################################################
variable "pid" {
   type        = string
   description = "GCP project."
   #default = "bsidesnyc2023"
   default = "hedonari-ablegu-oused-mit"
}

variable "module_avml_resources_installation_path" {
   type        = string
   description = "Installation path for the scripts. E.g. /home/gcp_test_user"
   #default = "/home/marshal"
   default = "/home/mhallberg"
}

variable "module_avml_resources_installation_user" {
   type        = string
   description = "The user to where installation scripts are stored. E.g. gcp_test_user"
   #default = "marshal"
   default = "mhallberg"
}

variable "zone" {
   type        = string
   description = "GCP zone in the var.region where resources are created."
   default = "europe-west1-b"
}

variable "region" {
   type        = string
   description = "GCP region where resources are created."
   default = "europe-west1-b"
}
########################################################################
# Define outputs
########################################################################
output "gcp_project" {
  value = module.avml_resources.gcp_project
}

output "zone" {
  value = module.avml_resources.zone
}

output "gcp_instance" {
  value = module.avml_resources.gcp_instance
}

output "gcp_instance_avml_sa" {
  value = module.avml_resources.gcp_instance_avml_sa
}

output "gcp_avml_bucket" {
  value = module.avml_resources.gcp_avml_bucket
}

output "volatility_script" {
  value = module.avml_resources.volatility_script
}

output "gke_cluster_name" {
  value = module.gke_cluster.gke_cluster_name
}

output "pod_name_avml" {
  value = module.gke_resources.pod_name_avml
}

output "pod_namespace_avml" {
  value = module.gke_resources.pod_namespace_avml
}

output "pod_name_att" {
  value = module.gke_resources.pod_name_att
}

output "pod_namespace_att" {
  value = module.gke_resources.pod_namespace_att
}
