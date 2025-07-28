output "zone_name" {
  value = google_dns_managed_zone.cloud_logging_enabled_zone.name
}

output "zone_dns_name" {
  value = google_dns_managed_zone.cloud_logging_enabled_zone.dns_name
}

output "dns_zone_nameservers" {
  value = google_dns_managed_zone.cloud_logging_enabled_zone.name_servers
}
