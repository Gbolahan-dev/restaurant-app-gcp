variable "database_url" {
  description = "The database connection string from Secret Manager."
  type        = string
  sensitive   = true
}

# 2. Create a Kubernetes secret in the staging namespace
resource "kubernetes_secret" "db_secret_staging" {
  metadata {
    name      = "restaurant-db-secret"
    namespace = kubernetes_namespace.staging.metadata[0].name
  }
  data = {
    DATABASE_URL = var.database_url
  }
  depends_on = [kubernetes_namespace.staging]
}

# 3. Create a Kubernetes secret in the production namespace
resource "kubernetes_secret" "db_secret_prod" {
  metadata {
    name      = "restaurant-db-secret"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }
  data = {
    DATABASE_URL = var.database_url
  }
  depends_on = [kubernetes_namespace.prod]
}
