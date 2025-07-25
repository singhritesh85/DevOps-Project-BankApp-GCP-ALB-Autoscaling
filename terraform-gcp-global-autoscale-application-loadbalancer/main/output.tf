output "gcp_instance_template_vm_instance_autoscale_alb_mysql_gitlab_vm_instance_private_and_static_ip_gcp_alb_static_ip" {
  description = "Details of the Google Cloud Instance Template, Instance Group, VM Instance, Autoscale, Application LoadBalancer and MySQL"
  value       = "${module.autoscale_alb}"
}
