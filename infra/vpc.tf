module "vpc" {
  # OLD:  source  = "terraform-google-modules/network/google"
  source = "./modules/network"          # ← new local path
  # delete any  version = "…"  line

  project_id   = var.project_id
  network_name = "restaurant-app-vpc"
  routing_mode = "GLOBAL"

  subnets = [{
    subnet_name   = "gke-subnet"
    subnet_ip     = "10.10.10.0/24"
    subnet_region = var.region
  }]
}

