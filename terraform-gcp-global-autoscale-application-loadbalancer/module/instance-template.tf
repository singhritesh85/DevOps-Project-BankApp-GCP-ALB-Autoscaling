# Service Account in GCP
resource "google_service_account" "bankapp_sa" {
  account_id   = "${var.prefix}-sa"
  display_name = "${var.prefix} Service Account"
}

# Attached GCP IAM Role to Service Account 
resource "google_project_iam_binding" "bankapp_sa_metric_role" {
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.bankapp_sa.email}",
  ]
}

# Attached GCP IAM Role to Service Account
resource "google_project_iam_binding" "bankapp_sa_log_role" {
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.bankapp_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_sa_role_compute_admin" {   ### will be used for Google Cloud Operations (Ops) Agent in a GKE cluster
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.bankapp_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_sa_role" {   ### will be used for Google Cloud Operations (Ops) Agent in a GKE cluster
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.bankapp_sa.email}",
  ]
}

# Instance Template in GCP
resource "google_compute_instance_template" "bankapp_template" {
  name        = "${var.prefix}-tempate"
  region      = var.gcp_region
  description = "This template is used to create Bank Application instances."

  labels = {    ### Key-Value Pair assigned to disk
    environment = var.env
  }

  instance_description = "Instances with Bank Application installed"   ### description to use for instances created from this template
  machine_type         = var.machine_type
  can_ip_forward       = false  ### Default is false
  tags                 = ["allow-ssh", "allow-health-check"]

  metadata_startup_script = file("startup-image-template.sh")

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
#   host_error_timeout_seconds = ""
    provisioning_model = "STANDARD"
  }

  # Creation of boot disk
  disk {
    source_image      = "rocky-linux-8-v20250610"
    auto_delete       = true
    boot              = true
### disk_name         = ""   ### When not provided, name of the disk will be defaults to the name of the instance.
    disk_type         = "pd-standard"
    architecture      = "x86_64"
    disk_size_gb      = 20
    resource_policies = [google_compute_resource_policy.daily_boot_disk_backup_twice.id]
  }

  # Use an extra disk
  disk {
    auto_delete = true
    boot        = false
    disk_type         = "pd-standard"
#    architecture      = "x86_64"
    disk_size_gb      = 10
    device_name       = "sdb"  ### Finally, device name will be /dev/sdb
    resource_policies = [google_compute_resource_policy.daily_extra_disk_backup_twice.id]
  }

  network_interface {
    network    = google_compute_network.gcp_vpc.id 
    subnetwork = google_compute_subnetwork.gcp_public_subnet.id
    access_config {
   
    }
  }

  metadata = {
    environment = var.env
  }

  service_account {
    email  = google_service_account.bankapp_sa.email
    scopes = ["cloud-platform"]
  }
}

# Disk Snapshot Policy
resource "google_compute_resource_policy" "daily_boot_disk_backup_twice" {
  name   = "bankapp-boot-disk-snapshot"
  region = var.gcp_region
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 12      ### Snapshots will be created after 12 hours
        start_time = "23:00"     ### Time is in UTC
      }
    }
    retention_policy {
      max_retention_days = 30    ### For one month snapshots will be kept.
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"  ### behavior for scheduled snapshots when the source disk is deleted
    }
    snapshot_properties {
      storage_locations = ["us-central1"]
###   guest_flush       = true  ### Application consistent snapshot will be used for databases and file servers.
    }
  }
}

resource "google_compute_resource_policy" "daily_extra_disk_backup_twice" {
  name   = "bankapp-extra-disk-snapshot"
  region = var.gcp_region
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 12      ### Snapshots will be created after 12 hours
        start_time = "23:00"     ### Time is in UTC
      }
    }
    retention_policy {
      max_retention_days = 30    ### For one month snapshots will be kept.
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"  ### behavior for scheduled snapshots when the source disk is deleted
    }
    snapshot_properties {
      storage_locations = ["us-central1"]
###   guest_flush       = true  ### Application consistent snapshot will be used for databases and file servers.
    }
  }
}
