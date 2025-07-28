######################################################## variables for VPC and EKS ################################################################

variable "region" {
  type = string
  description = "Provide the AWS Region into which EKS Cluster to be created"
}

variable "vpc_cidr"{
description = "Provide the CIDR for VPC"
type = string
#default = "10.10.0.0/16"
}

variable "private_subnet_cidr"{
description = "Provide the cidr for Private Subnet"
type = list
#default = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "public_subnet_cidr"{
description = "Provide the cidr of the Public Subnet"
type = list
#default = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
}

data "aws_partition" "amazonwebservices" {
}

data "aws_region" "reg" {
}

data "aws_availability_zones" "azs" {
}

data "aws_caller_identity" "G_Duty" {
}

variable "igw_name" {
description = "Provide the Name of Internet Gateway"
type = string
#default = "test-IGW"
}

variable "natgateway_name" {
description = "Provide the Name of NAT Gateway"
type = string
#default = "EKS-NatGateway"
}

variable "vpc_name" {
description = "Provide the Name of VPC"
type = string
#default = "test-vpc"
}

variable "env" {
  type = list
  description = "Provide the Environment for EKS Cluster and NodeGroup"
}

########################################### variables to launch EC2 ############################################################

variable "provide_ami" {
  description = "Provide the AMI ID for the EC2 Instance"
  type = map
}

variable "cidr_blocks" {
  description = "Provide the CIDR Block range"
  type = list
}

variable "instance_type" {
  type = list
  description = "Provide the Instance Type of EC2 Instance to be launched"
}

variable "disk_size" {
  type = number
  description = "Provide the EBS Disk Size"
}

variable "kms_key_id" {
  description = "Provide the KMS Key ID to Encrypt EBS"
  type = string
}

variable "name" {
  description = "Provide the name of the EC2 Instance"
  type = string
}

######################################################### Variables to create ALB for GitLab ################################################################

variable "application_loadbalancer_name" {
  description = "Provide the Application Loadbalancer Name"
  type = string
}
variable "internal" {
  description = "Whether the lodbalancer is internet facing or internal"
  type = bool
}
variable "load_balancer_type" {
  description = "Provide the type of the loadbalancer"
  type = string
}
variable "enable_deletion_protection" {
  description = "To disavle or enable the deletion protection of loadbalancer"
  type = bool
}
variable "s3_bucket_exists" {
  description = "Create S3 bucket only if doesnot exists."
  type = bool
}
variable "access_log_bucket" {
  description = "S3 bucket to capture Application LoadBalancer"
  type = string
}
variable "prefix_log" {
  description = "Provide the s3 bucket folder name"
  type = string
}
variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type = number
}
variable "enabled" {
  description = "To capture access log into s3 bucket or not"
  type = bool
}
variable "target_group_name" {
  description = "Provide Target Group Name for Application Loadbalancer"
  type = string
}
variable "instance_port" {    #### Don't apply when target_type is lambda
  description = "Instance Port on which Application will run"
  type = number
}
variable "instance_protocol" {          #####Don't use protocol when target type is lambda
  description = "The protocol to use for routing traffic to the targets."
  type = string
}
variable "target_type_alb" {
  description = "Select the target type of the Application LoadBalancer"
  type = list
}
variable "load_balancing_algorithm_type" {
  description = "Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups."
  type = list
}
variable "healthy_threshold" {
  description = "Provide healthy threshold in seconds, the number of checks before the instance is declared healthy"
  type = number
}
variable "unhealthy_threshold" {
  description = "Provide unhealthy threshold in seconds, the number of checks before the instance is declared unhealthy"
  type = number
}
variable "healthcheck_path" {
  description = "Provide the health check path"
  type = string
}
variable "timeout" {
  description = "Provide the timeout in seconds, the length of time before the check times out."
  type = number
}
variable "interval" {
  description = "The interval between checks."
  type = string
}
variable "ssl_policy" {
  description = "Select the SSl Policy for the Application Loadbalancer"
  type = list
}
variable "certificate_arn" {
  description = "Provide the SSL Certificate ARN from AWS Certificate Manager"
  type = string
}
variable "type" {
  description = "The type of routing action."
  type = list
}
