module "gitlab" {
  source = "../module"

############################# To create VPC ##############################

  vpc_cidr = var.vpc_cidr
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
  igw_name = var.igw_name
  natgateway_name = var.natgateway_name
  vpc_name = var.vpc_name
  env = var.env[0]

###########################To Launch EC2###################################

  instance_type = var.instance_type[3]
  provide_ami = var.provide_ami["us-east-2"]
  cidr_blocks = var.cidr_blocks
  disk_size   = var.disk_size
  kms_key_id  = var.kms_key_id
  name        = var.name

###########################To create ALB###################################

  application_loadbalancer_name = var.application_loadbalancer_name
  internal = var.internal
  load_balancer_type = var.load_balancer_type
  enable_deletion_protection = var.enable_deletion_protection
  s3_bucket_exists = var.s3_bucket_exists
  access_log_bucket = var.access_log_bucket  ### S3 Bucket into which the Access Log will be captured
  prefix_log = var.prefix_log
  idle_timeout = var.idle_timeout
  enabled = var.enabled
  target_group_name = var.target_group_name
  instance_port = var.instance_port
  instance_protocol = var.instance_protocol          #####Don't use protocol when target type is lambda
  target_type_alb = var.target_type_alb[0]
  healthcheck_path = var.healthcheck_path
  load_balancing_algorithm_type = var.load_balancing_algorithm_type[0]
  healthy_threshold = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  timeout = var.timeout
  interval = var.interval
  ssl_policy = var.ssl_policy[0]
  certificate_arn = var.certificate_arn
  type = var.type

}
