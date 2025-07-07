terraform {
  required_providers {
    google     = { source = "hashicorp/google", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.20" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.9" }
    random     = { source = "hashicorp/random",     version = "~> 3.5" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# This data source is still needed to get the access token for the user running terraform
data "google_client_config" "default" {}

#
# The data block for the cluster has been REMOVED.
# The providers below now get their values directly from the "resource" block in cluster.tf
#

provider "kubernetes" {
  host  = "https://${google_container_cluster.main.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.main.master_auth[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.main.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.main.master_auth[0].cluster_ca_certificate
    )
  }
}
