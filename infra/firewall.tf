# infra/firewall.tf

resource "google_compute_firewall" "allow_gke_nodeports" {
  project = var.project_id
  name    = "allow-gke-nodeports"
  network = module.vpc.network_name # Use the network created by our VPC module

  # Allow traffic from anywhere on the internet
  source_ranges = ["0.0.0.0/0"]

  # This rule allows traffic on the high-numbered ports that GKE uses
  # for LoadBalancer services (NodePorts).
  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
}
