variable "gke_service_account_name" {
   type        = string
   description = "New service account name."
   default = "demo-gke-sa"
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

variable "compute_engine_type" {
   type        = string
   description = "Compute engine type."
   default = "e2-standard-8"
}

variable "team_name" {
   type        = string
   description = "Name of the team owning the cluster"
   default     = "demo"
}
