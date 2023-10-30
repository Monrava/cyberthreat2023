#################################################################################
# Configure network firewall rule for 
#################################################################################
resource "google_compute_firewall" "demo-access-rule" {
  name    = "demo-access-rule"
  network = var.vpc

  allow {
    protocol = "tcp"
    ports    = ["8443", "1066", "22"]
  }

  source_ranges = ["35.235.240.0/20","10.132.0.0/20"]
}