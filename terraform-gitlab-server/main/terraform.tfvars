############################Provide Parameters for VPC################################

region = "us-east-2"

vpc_cidr = "10.10.0.0/16"
private_subnet_cidr = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
public_subnet_cidr = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
igw_name = "test-IGW"
natgateway_name = "EKS-NatGateway"
vpc_name = "test-vpc"
env = [ "dev", "stage", "prod" ]

##############################Parameters to launch EC2###############################

provide_ami = {
  "us-east-1" = "ami-05ffe3c48a9991133"
  "us-east-2" = "ami-0c803b171269e2d72"
  "us-west-1" = "ami-061ad72bc140532fd"
  "us-west-2" = "ami-05ee755be0cd7555c"
}
cidr_blocks = ["0.0.0.0/0"]
name = "GitLab-Server"
instance_type = ["t3.micro", "t3.small", "t3.medium", "t3.large"]
disk_size = "30"

kms_key_id = "arn:aws:kms:us-east-2:02XXXXXXXXX6:key/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"   ### Provide the ARN of KMS Key.

################################Parameters to create ALB############################

application_loadbalancer_name = "gitlab"
internal = false
load_balancer_type = "application"
enable_deletion_protection = false
s3_bucket_exists = false   ### Select between true and false. It true is selected then it will not create the s3 bucket.
access_log_bucket = "s3bucketcapturealbloggitlab" ### S3 Bucket into which the Access Log will be captured
prefix_log = "application_loadbalancer_log_folder"
idle_timeout = 60
enabled = true
target_group_name = "gitlab"
instance_port = 80
instance_protocol = "HTTP"          #####Don't use protocol when target type is lambda
target_type_alb = ["instance", "ip", "lambda"]
load_balancing_algorithm_type = ["round_robin", "least_outstanding_requests"]
healthy_threshold = 2
unhealthy_threshold = 2
timeout = 3
interval = 30
healthcheck_path = "/"
ssl_policy = ["ELBSecurityPolicy-2016-08", "ELBSecurityPolicy-TLS-1-2-2017-01", "ELBSecurityPolicy-TLS-1-1-2017-01", "ELBSecurityPolicy-TLS-1-2-Ext-2018-06", "ELBSecurityPolicy-FS-2018-06", "ELBSecurityPolicy-2015-05"]
certificate_arn = "arn:aws:acm:us-east-2:02XXXXXXXXX6:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
type = ["forward", "redirect", "fixed-response"]
