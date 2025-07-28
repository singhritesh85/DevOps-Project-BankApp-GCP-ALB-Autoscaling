output "EC2_Instance_GitLab_Server_Private_IP_Address" {
  description = "Private IP Address of GitLab Server EC2 Instance"
  value = aws_instance.gitlab_server.private_ip
}
output "GitLab_ALB_DNS_Name" {
  description = "The DNS name of the GitLab Server Application Load Balancer"
  value = aws_lb.test-application-loadbalancer-gitlab.dns_name
}
