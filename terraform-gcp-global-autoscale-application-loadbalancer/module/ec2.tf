########################################################## SonarQube Security Group #######################################################

# Security Group for SonarQube Server
resource "aws_security_group" "sonarqube" {
  name        = "SonarQube"
  description = "Security Group for SonarQube Server"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    security_groups  = [aws_security_group.sonarqube_alb.id]
  }

  ingress {
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["172.19.0.0/16"]
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
    Name = "SonarQube-Server-sg"
  }
}

############################################################# SonarQube Server ###########################################################################

resource "aws_instance" "sonarqube" {
  ami           = var.provide_ami
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.sonarqube.id]  ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                                 ###aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp2"
    volume_size="20"
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
  }
  user_data = file("user_data_sonarqube.sh")

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
    Name="SonarQube"
    Environment = var.env
    EBS-backed-AMI = "true"
  }

  depends_on = [aws_db_instance.dbinstance1]

}
resource "aws_eip" "eip_associate_sonarqube" {
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_sonarqube" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.sonarqube.id
  allocation_id = aws_eip.eip_associate_sonarqube.id
}

resource "null_resource" "sonarqube" {

  connection {
    type        = "ssh"
    user        = "ritesh"
    private_key = file("mykey.pem")
    host        = "${aws_eip.eip_associate_sonarqube.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 130",
      "sudo psql postgresql://postgres:Admin123@${aws_db_instance.dbinstance1.endpoint} -f /opt/sonarqube.sql",      
      "sudo sed -i '/#sonar.jdbc.username=/s//sonar.jdbc.username=sonarqube/' /opt/sonarqube/conf/sonar.properties",
      "sudo sed -i '/#sonar.jdbc.password=/s//sonar.jdbc.password=Cloud#436/' /opt/sonarqube/conf/sonar.properties",
      "sudo sed -i 's%#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube?currentSchema=my_schema%sonar.jdbc.url=jdbc:postgresql://${aws_db_instance.dbinstance1.endpoint}/sonarqubedb%g' /opt/sonarqube/conf/sonar.properties",
      "sudo systemctl restart sonarqube",
    ]
  }

  depends_on = [aws_instance.sonarqube, aws_eip_association.eip_association_sonarqube]

}

################################################# Nexus-Server Security Group #########################################################

# Security Group for Nexus-Server
resource "aws_security_group" "nexus" {
  name        = "Nexus"
  description = "Security Group for Nexus Server"
  vpc_id      = aws_vpc.test_vpc.id           ###var.vpc_id

  ingress {
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    security_groups  = [aws_security_group.nexus_alb.id]
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
    Name = "nexus-server-sg"
  }
}

########################################################## Nexus Server ##################################################################

resource "aws_instance" "nexus" {
  ami           = var.provide_ami
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.nexus.id]      ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id      ###var.subnet_id                                 ###aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp2"
    volume_size="20"
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
  }
  user_data = file("user_data_nexus.sh")

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
    Name="Nexus-Server"
    Environment = var.env
    EBS-backed-AMI = "true"
  }
}

resource "aws_eip" "eip_associate_nexus" {
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_nexus" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.nexus.id
  allocation_id = aws_eip.eip_associate_nexus.id
}

