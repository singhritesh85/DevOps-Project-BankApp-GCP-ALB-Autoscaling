resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.prefix}-vpc-peer-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.gcp_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.gcp_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "db_instance" {
  name             = "${var.prefix}-private-dbinstance-${random_id.db_name_suffix.hex}"
  region           = var.gcp_region
  database_version = var.database_version

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    edition = "ENTERPRISE"
    availability_type = "ZONAL"  ### "REGIONAL" For Multi-Zone or HA
    location_preference {
      zone = "us-central1-a"
###   secondary_zone = "us-central1-c"    ### will be used when availability_type = "REGIONAL" For Multi-Zone or HA
    }
    disk_autoresize = false
#   disk_autoresize_limit = 200 ### can be used only when disk_autoresize = true
    disk_size = 10
    disk_type = "PD_HDD"  ### "PD_SSD"  ### To save cloud cost I used PD_HDD for this project.
    tier = var.tier       ###"db-n1-standard-1"   ###"db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false   ### Assigned Public IP or not.
      private_network                               = google_compute_network.gcp_vpc.id
      enable_private_path_for_google_cloud_services = false
      ssl_mode = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"  ###"ENCRYPTED_ONLY" "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
      server_ca_mode = "GOOGLE_MANAGED_INTERNAL_CA"
    }
    backup_configuration {
      enabled = false ### true       ### Whether to enable or disable the backup.
      binary_log_enabled = false     ###true ### binary_log_enabled is enabled when backup is enabled.
      start_time = "11:00"
###   point_in_time_recovery_enabled = true ### Valid only for PostgreSQL and SQL Server instances. Will restart database if enabled after instance creation.
      location = var.gcp_region      ### Region where the backup will be stored.
      transaction_log_retention_days = 3 ### Between 1-7, For PostgreSQL Enterprise Plus instances 1-35.
      backup_retention_settings {
        retained_backups = 7
        retention_unit = "COUNT"
      }
    }
    maintenance_window {
      day = 7                   ###  1-7 starting on Monday
      hour = 20                 ###  Hour of day, provide a value in the range 0-23.
      update_track = "stable"     ###  Week to apply maintenance when a new version is available.
    }
    user_labels = {
      environment = var.env
    }
  }

  deletion_protection = false   ### Whether MySQL will be prevented from destroying
}

# Resource: Cloud SQL Database Schema
resource "google_sql_database" "dexter_dbschema" {
  name     = "bankappdb"
  instance = google_sql_database_instance.db_instance.name
}

# Resource: Cloud SQL Database User
resource "google_sql_user" "db_users" {
  name     = "dbadmin"
  instance = google_sql_database_instance.db_instance.name
  host     = "%"
  password = "Admin123"
}
