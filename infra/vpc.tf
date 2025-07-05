module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project_id
  network_name = "restaurant-app-vpc"
  routing_mode = "GLOBAL"

  # main subnet (unchanged)
  subnets = [
    {
      subnet_name   = "gke-subnet"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    }
  ]

  # ⬇️  tell the module which *existing* secondary range belongs to that subnet
  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = "gke-quote-api-cluster-pods-c024ec0d"
        ip_cidr_range = "10.176.0.0/14"
      }
    ]
  }
}

