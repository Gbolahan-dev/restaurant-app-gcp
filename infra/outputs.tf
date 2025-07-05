############################################
# 4. Outputs for easy reference
############################################

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/restaurant-app"
}
output "app_gsa_email" {
  value = google_service_account.app_gsa.email
}

output "cloudbuild_sa_email" {
  value = google_service_account.cloudbuild_sa.email
}

output "gke_node_sa_email" {
  value = google_service_account.gke_node_sa.email
}


output "gke_cluster_endpoint" {
  value = google_container_cluster.main.endpoint
}
output "gke_cluster_ca_certificate" {
  value = google_container_cluster.main.master_auth[0].cluster_ca_certificate
}


