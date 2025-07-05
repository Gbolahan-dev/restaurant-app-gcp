module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project_id
  network_name = "restaurant-app-vpc"
  routing_mode = "GLOBAL"

  subnets = [{
    subnet_name   = "gke-subnet"
    subnet_ip     = "10.10.10.0/24"
    subnet_region = var.region
  }]

  # NEW – tell the module’s resources to ignore Pod/Service ranges
  subnets_extra_tags = {
    gke-subnet = {
      lifecycle = {
        ignore_changes = ["secondary_ip_range"]
      }
    }
  }
}

