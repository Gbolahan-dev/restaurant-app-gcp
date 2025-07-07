# infra/variables.tf

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}


# This variable is required by cloudbuild_triggers.tf
variable "github_owner" {
  description = "The owner of the GitHub repository."
  type        = string
  default     = "Gbolahan-dev"
}

# This variable is required by cloudbuild_triggers.tf
variable "github_repo_name" {
  description = "The name of the GitHub repository."
  type        = string
  default     = "restaurant-app-gcp"
}

# This variable is required by helm.tf and passed in by cloudbuild.yaml
variable "image_tag" {
  description = "The Docker image tag to deploy."
  type        = string
  default     = "latest"
}

 variable "cluster_name" {
   description = "Name of the GKE cluster"
   type        = string
  default     = "quote-api-cluster"      # ← match the actual name
 }

variable "zone" {
  description = "GKE cluster zone"
  type        = string
  default     = "us-central1-a"           # ← where you ran `gcloud container clusters create`
}
