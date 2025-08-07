output "instance_template_id" {
  value = google_compute_instance_template.bankapp_template.id
}

output "instance_template_name" {
  value = google_compute_instance_template.bankapp_template.name
}

output "instance_template_self_link" {
  value = google_compute_instance_template.bankapp_template.self_link
}

output "db_instance_name" {
  value = google_sql_database_instance.db_instance.name
}

output "db_connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}

output "db_instance_private_ip_address" {
  value = google_sql_database_instance.db_instance.private_ip_address
}

output "gitlab_runner_vm_instance_private_ip_address" {
  value = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "gitlab_runner_vm_instance_public_ip_address" {
  value = google_compute_address.vm_static_ip.address
}

output "gcp_alb_static_ip" {
  value = google_compute_global_address.alb_static_ip.address
}
