# helm.tf
resource "helm_release" "staging" {
  name             = "restaurant-app-staging"
  chart            = "../charts/restaurant-app" # Path to new chart
  namespace        = kubernetes_namespace.staging.metadata[0].name
  create_namespace = false

  set {
    name  = "image.repository"
    value = "${google_artifact_registry_repository.app_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/restaurant-app"
  }
  set {
    name  = "image.tag"
    value = var.image_tag
  }
  set {
    name  = "serviceAccount.name"
    value = "restaurant-app-ksa"
  }
}

resource "helm_release" "production" {
  name             = "restaurant-app-prod"
  chart            = "../charts/restaurant-app" # Path to new chart
  namespace        = kubernetes_namespace.prod.metadata[0].name
  create_namespace = false

  set {
    name  = "image.repository"
    value = "${google_artifact_registry_repository.app_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/restaurant-app"
  }
  set {
    name  = "image.tag"
    value = var.image_tag
  }
  set {
    name  = "serviceAccount.name"
    value = "restaurant-app-ksa"
  }
}

