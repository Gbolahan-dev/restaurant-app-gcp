# --- Enable APIs ---
resource "google_project_service" "sql_apis" {
  for_each = toset(["sqladmin.googleapis.com", "servicenetworking.googleapis.com"])
  project  = var.project_id
  service  = each.key
}

# --- VPC Peering for Cloud SQL ---
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project_id
  name          = "restaurant-app-db-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_project_service.sql_apis]
}

# --- Database Instance ---
resource "google_sql_database_instance" "main_db" {
  project             = var.project_id
  name                = "restaurant-db-instance"
  database_version    = "POSTGRES_14"
  region              = var.region
  deletion_protection = false

  settings {
    tier = "db-g1-small"
    ip_configuration {
      ipv4_enabled    = false # No public IP
      private_network = module.vpc.network_self_link
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# --- Database and User ---
resource "google_sql_database" "app_db" {
  project  = var.project_id
  instance = google_sql_database_instance.main_db.name
  name     = "restaurantdb"
}

resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "google_sql_user" "db_user" {
  project  = var.project_id
  instance = google_sql_database_instance.main_db.name
  name     = "restaurant_user"
  password = random_password.db_password.result
}
