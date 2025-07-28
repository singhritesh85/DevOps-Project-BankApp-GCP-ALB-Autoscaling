output "ec2_private_ip_alb_dns" {
  description = "Details of EC2 Instances Private IPs and ALB DNS Name"
  value       = "${module.gitlab}"
}
