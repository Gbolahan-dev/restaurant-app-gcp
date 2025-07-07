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

# Add this new block to the end of infra/outputs.tf

/*
output "debug_database_url_from_secret_manager" {
  description = "DEBUG: This forces Terraform to read the secret and will fail if permissions are wrong."
  value       = data.google_secret_manager_secret_version.db_url.secret_data
  sensitive   = true # This prevents the actual password from printing in the public logs
}
*/
