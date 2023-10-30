variable "pid" {}

variable "zone" {
   type        = string
   description = "GCP zone in the var.region where resources are created."
   default = "europe-west1"
}
