resource "google_container_cluster" "demo-gke-cluster" {
  name                        = "demo-gke-cluster"
  location                    = var.zone
  # Remeber to specify VPC.
  network                     = var.vpc
  remove_default_node_pool    = true
  enable_intranode_visibility = false
  initial_node_count          = 1
  deletion_protection         = false

  #Configure node.
  node_config {
    preemptible     = true
    machine_type    = var.compute_engine_type
    tags            = [google_compute_firewall.demo-access-rule.name]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.demo-gke-sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      team = var.team_name
    }
  }
}
#################################################################################
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
#################################################################################
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name              = "demo-gke-node-pool"
  location          = var.zone
  cluster           = google_container_cluster.demo-gke-cluster.id
  node_count        = 1

  node_config {
    preemptible     = true
    machine_type    = var.compute_engine_type
    tags            = [google_compute_firewall.demo-access-rule.name]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.demo-gke-sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels = {
      team = var.team_name
    }
  }
}
