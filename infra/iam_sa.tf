# Pod Service Account
resource "google_service_account" "app_gsa" {
  account_id   = "restaurant-app-gsa"
  display_name = "GSA for Restaurant App Pods"
}
resource "google_project_iam_member" "app_gsa_permissions" {
  for_each = toset(["roles/artifactregistry.reader", "roles/logging.logWriter", "roles/cloudsql.client"])
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.app_gsa.email}"
}



# Workload Identity Bindings
resource "google_service_account_iam_member" "app_gsa_wi_user_staging" {
  service_account_id = google_service_account.app_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.staging.metadata[0].name}/restaurant-app-ksa]"
  depends_on = [kubernetes_namespace.staging]

}
resource "google_service_account_iam_member" "app_gsa_wi_user_prod" {
  service_account_id = google_service_account.app_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.prod.metadata[0].name}/restaurant-app-ksa]"
  depends_on = [kubernetes_namespace.prod]
}



# Cloud Build Service Account
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "restaurant-app-cb-sa"
  display_name = "Cloud Build SA for Restaurant App"
}
resource "google_project_iam_member" "cb_sa_permissions" {
  for_each = toset([
    "roles/artifactregistry.writer", "roles/container.developer", "roles/logging.logWriter",
    "roles/iam.serviceAccountUser", "roles/container.clusterViewer", "roles/compute.viewer",
    "roles/iam.serviceAccountViewer", "roles/cloudsql.admin", "roles/secretmanager.secretAccessor"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}
resource "google_storage_bucket_iam_member" "cb_sa_tf_state_bucket_object_admin" {
  bucket = "tf-state-daring-emitter-457812-v7"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# GKE Node Pool Service Account
resource "google_service_account" "gke_node_sa" {
  account_id   = "restaurant-app-node-sa"
  display_name = "GKE Node Pool SA for Restaurant App"
}
resource "google_project_iam_member" "node_sa_permissions" {
  for_each = toset(["roles/artifactregistry.reader", "roles/logging.logWriter", "roles/monitoring.metricWriter"])
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.gke_node_sa.email}"
}
