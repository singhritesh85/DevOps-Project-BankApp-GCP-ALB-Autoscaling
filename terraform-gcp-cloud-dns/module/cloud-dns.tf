resource "google_dns_managed_zone" "cloud_logging_enabled_zone" {
  name        = "public-hosted-zone-logging-enabled"
  dns_name    = var.dns_name
  description = "cloud logging enabled Public DNS zone"
  visibility  = var.dns_zone_visibility

  cloud_logging_config {
    enable_logging = var.enable_logging
  }

  dnssec_config {
    state = var.dnssec_state
  }

}
