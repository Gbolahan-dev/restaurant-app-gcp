# infra/cloudbuild_triggers.tf

# Trigger for the main pipeline (merges to main branch)
resource "google_cloudbuild_trigger" "prod" {
  project     = var.project_id
  name        = "restaurant-app-prod-trigger"
  description = "Push to main -> build, push, deploy restaurant-app to GKE"
  filename    = "cloudbuild.yaml"

  # Use the new, refactored Cloud Build service account
  service_account = google_service_account.cloudbuild_sa.id

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _TARGET_ENV = "prod"
  }
}

# Trigger for the PR validation pipeline
resource "google_cloudbuild_trigger" "pr" {
  project     = var.project_id
  name        = "restaurant-app-pr-trigger"
  description = "PR to main -> Run validation checks for restaurant-app"
  filename    = "cloudbuild.pr.yaml"

  # Use the new, refactored Cloud Build service account
  service_account = google_service_account.cloudbuild_sa.id

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_DISABLED"
    }
  }
}
