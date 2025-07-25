variable "project_name" {

}

variable "gcp_region" {

}

variable "prefix" {

}

variable "ip_range_subnet" {

}

variable "ip_public_range_subnet" {

}

variable "ip_proxy_range_subnet" {

}

variable "machine_type" {

}

variable "database_version" {

}

variable "tier" {

}

variable "env" {

}

######################################################## variables for VPC in AWS ################################################################

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

########################################### variables to launch EC2 in AWS ############################################################

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

######################################################### Variables to create ALB in AWS ################################################################

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

##################################### Variables for RDS in AWS ########################################################

variable "identifier" {

}
variable "db_subnet_group_name" {

}
#variable "rds_subnet_group" {

#}
#variable "read_replica_identifier" {

#}
variable "allocated_storage" {

}
variable "max_allocated_storage" {

}
#variable "read_replica_max_allocated_storage" {

#}
variable "storage_type" {

}
#variable "read_replica_storage_type" {

#}
variable "engine" {

}
variable "engine_version" {

}
variable "instance_class" {

}
#variable "read_replica_instance_class" {

#}
variable "rds_db_name" {

}
variable "username" {

}
variable "password" {

}
variable "parameter_group_name" {

}
variable "multi_az" {

}
#variable "read_replica_multi_az" {

#}
#variable "final_snapshot_identifier" {

#}
variable "skip_final_snapshot" {

}
#variable "copy_tags_to_snapshot" {

#}
variable "availability_zone" {

}
variable "publicly_accessible" {

}
#variable "read_replica_vpc_security_group_ids" {

#}
#variable "backup_retention_period" {

#}
variable "kms_key_id_rds" {

}
#variable "read_replica_kms_key_id" {

#}
variable "monitoring_role_arn" {

}
variable "enabled_cloudwatch_logs_exports" {

}
