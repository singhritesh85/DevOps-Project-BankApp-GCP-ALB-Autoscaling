######################################################## variables for VPC ################################################################

variable "vpc_cidr"{

}

variable "private_subnet_cidr"{

}

variable "public_subnet_cidr"{

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

}

variable "natgateway_name" {

}

variable "vpc_name" {

}

variable "env" {

}

########################################### variables to launch EC2 ############################################################

variable "provide_ami" {

}

variable "cidr_blocks" {

}

variable "instance_type" {

}

variable "disk_size" {

}

variable "kms_key_id" {

}

variable "name" {

}

######################################################### Variables to create ALB for GitLab ################################################################

variable "application_loadbalancer_name" {

}
variable "internal" {

}
variable "load_balancer_type" {

}
variable "enable_deletion_protection" {

}
variable "s3_bucket_exists" {

}
variable "access_log_bucket" {

}
variable "prefix_log" {

}
variable "idle_timeout" {

}
variable "enabled" {

}
variable "target_group_name" {

}
variable "instance_port" {    #### Don't apply when target_type is lambda

}
variable "instance_protocol" {          #####Don't use protocol when target type is lambda

}
variable "target_type_alb" {

}
variable "load_balancing_algorithm_type" {

}
variable "healthy_threshold" {

}
variable "unhealthy_threshold" {

}
variable "healthcheck_path" {

}
variable "timeout" {

}
variable "interval" {

}
variable "ssl_policy" {

}
variable "certificate_arn" {

}
variable "type" {

}
