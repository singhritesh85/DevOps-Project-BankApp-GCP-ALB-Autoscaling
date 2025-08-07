################## Parameters for GCP to be used for the Project ######################

project_name = "XXXX-XXXXXXX-2XXXXX6"  ### Provide the GCP Account Project ID. 

gcp_region = ["us-east1", "us-central1", "asia-south2", "asia-south1", "us-west1"]

prefix = "bankapp"

ip_range_subnet = "192.168.0.0/24"

ip_public_range_subnet = "172.20.0.0/24"

ip_proxy_range_subnet = "172.20.1.0/24"

machine_type = ["n1-standard-1", "e2-small", "e2-medium", "n2-standard-4", "c2-standard-4", "c3-standard-4"]

database_version = ["MYSQL_5_6", "MYSQL_5_7", "MYSQL_8_0", "POSTGRES_11", "POSTGRES_12", "POSTGRES_13", "POSTGRES_14", "POSTGRES_15"]

tier = ["db-f1-micro", "db-n1-standard-1", "db-e2-small", "db-e2-medium", "db-n2-standard-4", "db-c2-standard-4", "db-c3-standard-4"]

env = [ "dev", "stage", "prod" ]

############################Provide Parameters for VPC in AWS################################

region = "us-east-2"

vpc_cidr = "172.19.0.0/16"
private_subnet_cidr = ["172.19.1.0/24", "172.19.2.0/24", "172.19.3.0/24"]
public_subnet_cidr = ["172.19.4.0/24", "172.19.5.0/24", "172.19.6.0/24"]
igw_name = "bankapp-IGW"
natgateway_name = "bankapp-NatGateway"
vpc_name = "bankapp-vpc"

##############################Parameters to launch EC2 in AWS###############################

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

################################Parameters to create ALB in AWS############################

application_loadbalancer_name = "sonarqube"
internal = false
load_balancer_type = "application"
enable_deletion_protection = false
s3_bucket_exists = false   ### Select between true and false. It true is selected then it will not create the s3 bucket.
access_log_bucket = "s3bucketcapturealblogsonarqube" ### S3 Bucket into which the Access Log will be captured
prefix_log = "application_loadbalancer_log_folder"
idle_timeout = 60
enabled = true
target_group_name = "sonarqube"
instance_port = 9000
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

############################################### RDS DB Instance in AWS Parameters ###############################################

  db_instance_count = 1
  identifier = "dbinstance-1"
  db_subnet_group_name = "rds-subnetgroup"        ###  postgresql-subnetgroup
#  rds_subnet_group = ["subnet-XXXXXXXXXXXXX", "subnet-XXXXXXXXXXXXXX", "subnet-XXXXXXXXXXXXXXX", "subnet-XXXXXXXXXXXXXXX", "subnet-XXXXXXXXXXXXXX", "subnet-XXXXXXXXXXXXXX"]
#  read_replica_identifier = "dbinstance-readreplica-1"
  allocated_storage = 20
  max_allocated_storage = 100
#  read_replica_max_allocated_storage = 100
  storage_type = ["gp2", "gp3", "io1", "io2"]
#  read_replica_storage_type = ["gp2", "gp3", "io1", "io2"]
  engine = ["mysql", "mariadb", "mssql", "postgres"]
  engine_version = ["5.7.44", "8.0.33", "8.0.35", "8.0.36", "10.4.30", "10.5.20", "10.11.6", "10.11.7", "13.00.6435.1.v1", "14.00.3421.10.v1", "15.00.4365.2.v1", "14.9", "14.10", "14.11", "14.12", "15.5", "16.1"] ### For postgresql select version = 14.9 and for MySQL select version = 5.7.44
  instance_class = ["db.t3.micro", "db.t3.small", "db.t3.medium", "db.t3.large", "db.t3.xlarge", "db.t3.2xlarge"]
#  read_replica_instance_class = ["db.t3.micro", "db.t3.small", "db.t3.medium", "db.t3.large", "db.t3.xlarge", "db.t3.2xlarge"]
  rds_db_name = "mydb"
  username = "postgres"   ### For MySQL select username as admin and For PostgreSQL select username as postgres
  password = "Admin123"          ### "Sonar123" use this password for PostgreSQL
  parameter_group_name = ["default.mysql5.7", "default.postgres14"]
  multi_az = ["false", "true"]   ### select between true or false
#  read_replica_multi_az = false   ### select between true or false
#  final_snapshot_identifier = "database-1-final-snapshot-before-deletion"   ### Here I am using it for demo and not taking final snapshot while db instance is deleted
  skip_final_snapshot = ["true", "false"]
#  copy_tags_to_snapshot = true   ### Select between true or false
  availability_zone = ["us-east-2a", "us-east-2b", "us-east-2c"]
  publicly_accessible = ["true", "false"]  #### Select between true or false
#  read_replica_vpc_security_group_ids = ["sg-038XXXXXXXXXXXXc291", "sg-a2XXXXXXca"]
#  backup_retention_period = 7   ### For Demo purpose I am not creating any db backup.
  kms_key_id_rds = "arn:aws:kms:us-east-2:02XXXXXXXXX6:key/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
#  read_replica_kms_key_id = "arn:aws:kms:us-east-2:027XXXXXXX06:key/20XXXXXXf3-aXXc-4XXd-9XX4-24XXXXXXXXXX17"  ### I am not using any read replica here.
  monitoring_role_arn = "arn:aws:iam::02XXXXXXXXX6:role/rds-monitoring-role"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]   ### ["audit", "error", "general", "slowquery"]  for MySQL
