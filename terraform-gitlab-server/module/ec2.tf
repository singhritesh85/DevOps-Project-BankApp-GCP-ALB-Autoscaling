############################################################### GitLab-Server #####################################################################
# Security Group for GitLab-Server
resource "aws_security_group" "gitlab_server" {
  name        = "GitLab-Server"
  description = "Security Group for GitLab Server ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.gitlab_server_alb.id]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "GitLab-Server-sg"
  }
}

resource "aws_instance" "gitlab_server" {
  ami           = var.provide_ami
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.gitlab_server.id]      ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                                 ###aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp2"
    volume_size=var.disk_size
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
    tags={
      Snapshot = "true"
      Environment = var.env 
      Name="${var.name}-root-volume"
    }
  }
  iam_instance_profile = "Administrator_Access"    ###aws_iam_instance_profile.ec2_instance_profile.name   ### IAM Role to be attached to EC2
  user_data = file("user_data_gitlab_server.sh")

  lifecycle{
    prevent_destroy=false
    ignore_changes=[ ami ]
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  metadata_options { #Enabling IMDSv2
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  tags={
    Name="${var.name}"
    Environment = var.env
  }

}

resource "aws_eip" "eip_associate_gitlab" {
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_gitlab" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.gitlab_server.id
  allocation_id = aws_eip.eip_associate_gitlab.id
}

resource "null_resource" "gitlab_server" {

  provisioner "remote-exec" {
    inline = [
         "sleep 150",
         "sudo yum install -y policycoreutils-python-utils openssh-server openssh-clients perl",
         "curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash",
         "sudo EXTERNAL_URL=\"http://gitlab.singhritesh85.com\" yum install -y gitlab-ee",
###      "sudo gitlab-ctl reconfigure",  ### Need to run when you do changes in /etc/gitlab/gitlab.rb
         "sudo gitlab-ctl start",
         "sudo gitlab-ctl status",
    ]
  }
  connection {
    type = "ssh"
    host = aws_eip.eip_associate_gitlab.public_ip
    user = "ritesh"
    private_key = file("mykey.pem")
  }

  depends_on = [aws_instance.gitlab_server, aws_eip_association.eip_association_gitlab]

}
