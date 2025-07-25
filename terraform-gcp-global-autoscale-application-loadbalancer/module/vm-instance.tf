###################################################### Create Service Account #####################################################

resource "google_service_account" "bankapp_gke_sa" {
  account_id   = "${var.prefix}-gke-sa"
  display_name = "${var.prefix} Service Account"
}

resource "google_project_iam_binding" "bankapp_gke_sa_role_compute_admin" {   ### will be used for Google Cloud Operations (Ops) Agent in a GKE cluster
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.bankapp_gke_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_gke_sa_role" {   ### will be used for Google Cloud Operations (Ops) Agent in a GKE cluster
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.bankapp_gke_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_gke_sa_role_monitoring_viewer" {
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/monitoring.viewer"
  members = [
    "serviceAccount:${google_service_account.bankapp_gke_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_gke_sa_role_log_viewer" {
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/logging.viewer"
  members = [
    "serviceAccount:${google_service_account.bankapp_gke_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_gke_sa_role_log_writer" {    ### will be used for Google Cloud Operations (Ops) Agent in a GKE cluster
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.bankapp_gke_sa.email}",
  ]
}

resource "google_project_iam_binding" "bankapp_gke_sa_role_monitoring_writer" {   ### will be used for Google Cloud Operations (Ops) Agent in a GKE cluster
  project = var.project_name  ### Project ID for your Google Account
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.bankapp_gke_sa.email}",
  ]
}

############################################ Reserver Internal IP Address for GCP VM Instance ###################################################

resource "google_compute_address" "instance_internal_ip" {
  name         = "${var.prefix}-instance-internal-ip"
  description  = "Internal IP address reserved for VM Instance"
  address_type = "INTERNAL"
  region       = var.gcp_region
  subnetwork   = google_compute_subnetwork.gcp_public_subnet.id 
  address      = "172.20.0.100"
}

############################################# Create a single Compute Engine VM instance ########################################################

resource "google_compute_address" "vm_static_ip" {
  name         = "gitlab-runner-static-ip"
  address_type = "EXTERNAL"
  region       = "us-central1"  # Replace with your desired region
  ip_version   = "IPV4"         # Default value is IPV4
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.prefix}-gitlab-runner"
  machine_type = var.machine_type
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "rocky-linux-8-v20250610"
      size  = 20
      type  = "pd-standard" ### Select among pd-standard, pd-balanced or pd-ssd.
      architecture = "X86_64"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.gcp_public_subnet.id
    network_ip = google_compute_address.instance_internal_ip.address
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address   ### Static IP Assigned to GCP VM Instance.
    }
  }
  service_account {
    email = google_service_account.bankapp_gke_sa.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = file("startup.sh")

  tags = ["allow-ssh"]

}
