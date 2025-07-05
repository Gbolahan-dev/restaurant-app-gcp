resource "google_container_cluster" "main" {
  project                  = var.project_id
  name                     = var.cluster_name
  location                 = var.region # Using region for a regional cluster
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = module.vpc.network_name
  subnetwork               = module.vpc.subnets_names[0]

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }
}

resource "google_container_node_pool" "main_pool" {
  name     = "main-pool"
  cluster  = google_container_cluster.main.name
  location = var.region
  project  = var.project_id

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_node_sa.email
    image_type      = "COS_CONTAINERD"
    disk_size_gb    = 30
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
