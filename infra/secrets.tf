# --- Database Connection Secret ---

locals {
  # Construct the connection URL. Note we use the instance's private_ip_address
  database_url = "postgresql://${google_sql_user.db_user.name}:${random_password.db_password.result}@${google_sql_database_instance.main_db.private_ip_address}:5432/${google_sql_database.app_db.name}"
}

# --- Create Kubernetes Secrets ---
# Terraform will create these K8s secrets directly in the cluster
resource "kubernetes_secret" "db_secret_staging" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.staging.metadata[0].name
  }
  data = {
    DATABASE_URL = local.database_url
  }
  type = "Opaque"
}

resource "kubernetes_secret" "db_secret_prod" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }
  data = {
    DATABASE_URL = local.database_url
  }
  type = "Opaque"
}

