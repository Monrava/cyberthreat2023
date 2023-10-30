#################################################################################
# Define required providers
#################################################################################
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}
#################################################################################
# Define outputs for the other config
#################################################################################
output "pod_name_avml" {
  value = kubernetes_pod.pod_node_affinity_memory_dump.metadata[0].name
}

output "pod_namespace_avml" {
  value = kubernetes_namespace.namespace_demo_mem_dump.metadata[0].name
}

output "pod_name_att" {
  value = kubernetes_pod.pod_node_affinity_attacker_pod.metadata[0].name
}

output "pod_namespace_att" {
  value = "default"
}
