module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project_id
  network_name = "restaurant-app-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "gke-subnet"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    }
  ]
}
