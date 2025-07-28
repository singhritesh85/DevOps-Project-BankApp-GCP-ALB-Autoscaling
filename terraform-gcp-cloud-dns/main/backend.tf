terraform {
  backend "gcs" {
    bucket  = "dolo-dempo"
    prefix  = "cloud-dns"
  }
}


