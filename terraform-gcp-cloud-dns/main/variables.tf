variable "project_name" {
  description = "Provide the project name in GCP Account"
  type = string
}

variable "gcp_region" {
  description = "Provide the GCP Region in which Resources to be created"
  type = list
}

variable "dns_name" {
  description = "Provide the DNS Name"
  type = string
}

variable "dns_zone_visibility" {
  description = "Select the DNS Zone Visibility between Public and Private"
  type = list
}

variable "enable_logging" {
  description = "Select do you want to enable or disable the logging"
  type = list
}

variable "dnssec_state" {
  description = "Select do you want to enable or disable the dnssec"
  type = list
}
