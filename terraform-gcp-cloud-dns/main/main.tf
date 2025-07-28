module "gcp_cloud_dns" {

  source = "../module"
  project_name = var.project_name
  gcp_region = var.gcp_region[1]
  dns_name = var.dns_name
  dns_zone_visibility = var.dns_zone_visibility[0]
  enable_logging = var.enable_logging[0] 
  dnssec_state = var.dnssec_state[0] 

}
