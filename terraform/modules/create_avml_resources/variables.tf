variable "new_service_account_name" {
   type        = string
   description = "New service account name."
   default = "tf-avml-sa"
}

variable "pid" {}

variable "region" {
   type        = string
   description = "GCP region where resources are created."
   default = "europe-west1"
}

variable "zone" {
   type        = string
   description = "GCP zone in the var.region where resources are created."
   default = "europe-west1-b"
}

variable "vpc" {
   type        = string
   description = "GCP project VPC."
   default = "default"
}

variable "base_image" {
   type        = string
   description = "Base image for compute engines."
   default = "debian-cloud/debian-10"
}

variable "disk_size" {
   type         = string
   description  = "Base image for compute engines."
   default      = "500"
}

variable "machine_type" {
   type        = string
   description = "Base image for compute engines."
   default = "e2-standard-8"
}

variable "installation_script" {
   type        = string
   description = "Installation dependency script name."
   default = "install_dependencies.sh"
}

variable "installation_script_bucket_path" {
   type        = string
   description = "The path to where installation scripts are stored in the."
   default = "avml_instance_scripts"
}

variable "installation_path" {}

variable "installation_user" {}

variable "volatility_script" {
   type        = string
   description = "The installation script name."
   default = "volatility_commands.sh"
}