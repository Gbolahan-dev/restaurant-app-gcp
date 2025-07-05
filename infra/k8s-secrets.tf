# infra/k8s-secrets.tf

# 1. Look up the Neon DB URL from the secure Secret Manager
data "google_secret_manager_secret_version" "db_url" {
  secret  = "restaurant-db-url" # The name of the secret you created with gcloud
}

# 2. Create a Kubernetes secret in the staging namespace
resource "kubernetes_secret" "db_secret_staging" {
  metadata {
    name      = "restaurant-db-secret" # We'll use the same secret name in both namespaces
    namespace = kubernetes_namespace.staging.metadata[0].name
  }
  data = {
    DATABASE_URL = data.google_secret_manager_secret_version.db_url.secret_data
  }
}

# 3. Create a Kubernetes secret in the production namespace
resource "kubernetes_secret" "db_secret_prod" {
  metadata {
    name      = "restaurant-db-secret"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }
  data = {
    DATABASE_URL = data.google_secret_manager_secret_version.db_url.secret_data
  }
}
