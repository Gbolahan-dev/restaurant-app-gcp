resource "google_compute_firewall" "allow_gke_lb_3000" {
  project = var.project_id
  name    = "allow-gke-lb-3000"
  network = module.vpc.network_name

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["gke-node"] # Make sure this matches your node pool tags

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
}

