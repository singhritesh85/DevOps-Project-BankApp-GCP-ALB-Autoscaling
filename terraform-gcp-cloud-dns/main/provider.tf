provider "google" {
  project = var.project_name  ### Provide Project ID for your GCP Account
  region  = "us-central1"    ###var.gcp_region[1]
}
