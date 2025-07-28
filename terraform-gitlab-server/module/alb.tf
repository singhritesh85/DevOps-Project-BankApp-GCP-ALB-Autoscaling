####################################################### GitLab Server ALB ########################################################

# Security Group for GitLab Server ALB
resource "aws_security_group" "gitlab_server_alb" {
  name        = "GitLab-Server-ALB"
  description = "Security Group for GitLab Server ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  ingress {
    protocol   = "tcp"
    cidr_blocks = var.cidr_blocks
    from_port  = 80
    to_port    = 80
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "GitLab-Server-ALB-sg"
  }
}

#S3 Bucket to capture ALB access logs
resource "aws_s3_bucket" "s3_bucket_gitlab" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = var.access_log_bucket

  force_destroy = true

  tags = {
    Environment = var.env
  }
}

#S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3bucket_encryption_gitlab" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_gitlab[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

#Apply Bucket Policy to S3 Bucket
resource "aws_s3_bucket_policy" "s3bucket_policy_gitlab" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_gitlab[0].id
  policy = <<EOF
    {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": "arn:aws:iam::033677994240:root"
         },
         "Action": "s3:PutObject",
         "Resource": "arn:aws:s3:::s3bucketcapturealbloggitlab/application_loadbalancer_log_folder/AWSLogs/${data.aws_caller_identity.G_Duty.account_id}/*"
         }
       ]
    }     
  EOF

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.s3bucket_encryption_gitlab]
}

#Application Loadbalancer GitLab Server
resource "aws_lb" "test-application-loadbalancer-gitlab" {
  name               = var.application_loadbalancer_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.gitlab_server_alb.id]           ###var.security_groups
  subnets            = aws_subnet.public_subnet.*.id

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout = var.idle_timeout
  access_logs {
    bucket  = var.access_log_bucket
    prefix  = var.prefix_log
    enabled = var.enabled
  }

  tags = {
    Environment = var.env
  }

  depends_on = [aws_s3_bucket_policy.s3bucket_policy_gitlab]
}

#Target Group of Application Loadbalancer GitLab Server
resource "aws_lb_target_group" "target_group_gitlab" {
  name     = var.target_group_name
  port     = var.instance_port      ##### Don't use protocol when target type is lambda
  protocol = var.instance_protocol  ##### Don't use protocol when target type is lambda
  vpc_id   = aws_vpc.test_vpc.id
  target_type = var.target_type_alb
  load_balancing_algorithm_type = var.load_balancing_algorithm_type
  health_check {
    enabled = true ## Indicates whether health checks are enabled. Defaults to true.
    path = var.healthcheck_path     ###"/index.html"
    port = "traffic-port"
    protocol = "HTTP"
    matcher             = "200,301,302"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
  }
}

###GitLab Server Application Loadbalancer listener for HTTP
resource "aws_lb_listener" "alb_listener_front_end_HTTP_GitLab" {
  load_balancer_arn = aws_lb.test-application-loadbalancer-gitlab.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = var.type[1]
    target_group_arn = aws_lb_target_group.target_group_gitlab.arn
     redirect {    ### Redirect HTTP to HTTPS
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

##GitLab Server Application Loadbalancer listener for HTTPS
resource "aws_lb_listener" "alb_listener_front_end_HTTPS" {
  load_balancer_arn = aws_lb.test-application-loadbalancer-gitlab.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = var.type[0]
    target_group_arn = aws_lb_target_group.target_group_gitlab.arn
  }
}

## EC2 Instance1 attachment to GitLab Server Target Group
resource "aws_lb_target_group_attachment" "ec2_instance1_attachment_to_tg_gitlab" {
  target_group_arn = aws_lb_target_group.target_group_gitlab.arn
  target_id        = aws_instance.gitlab_server.id               #var.ec2_instance_id[0]
  port             = var.instance_port
}

## EC2 Instance2 attachment to Target Group
#resource "aws_lb_target_group_attachment" "ec2_instance2_attachment_to_tg" {
#  target_group_arn = aws_lb_target_group.target_group.arn
#  target_id        = var.ec2_instance_id[1]
#  port             = var.instance_port
#}
