################################################## Lifecycle Manager to create EBS backed AMI of EC2 #################################################

resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "dlm-lifecycle-role-ami"
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "dlm.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "dlm-lifecycle-policy-ami"
  role   = aws_iam_role.dlm_lifecycle_role.id
  policy = jsonencode({
    "Version": "2012-10-17"
    "Statement":  [
      {
        "Action": [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateImage",
          "ec2:DeregisterImage",
          "ec2:DescribeImages",
        ],
        "Effect": "Allow",
        "Resource": ["*"]
      },
      {
        "Action": [
          "ec2:CreateTags"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:*::snapshot/*",
          "arn:aws:ec2:us-east-2::image/*",
        ]
      }
    ]
  })
}

resource "aws_dlm_lifecycle_policy" "ami_lifecycle" {
  description        = "DLM lifecycle policy for EBS backed AMI"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]
    policy_type    = "IMAGE_MANAGEMENT"

    schedule {
      name = "daily ebs-backed-ami to be kept for 30 days"

      create_rule {
        interval      = 12
        interval_unit = "HOURS"
        times         = ["08:01"]   ###["11:00"]  ### First Snapshot will be created at 11 O'clock UTC in night and the 11 O'clock UTC in the morning.
      }

      retain_rule {
        count = 60    ### Keep last 60 copies which is last 30 days of AMIs before descard it.
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true  ### Do you want to copy tags from the source EC2 to the AMIs.
    }

    parameters {
      no_reboot = true  ### Prevents rebooting instances
    }

    target_tags = {
      EBS-backed-AMI = "true"   ### This tags should be present in the EC2 which AMI needs to be created.
    }

  }
  tags = {
    Name = "lifecycle-policy-ebs-backed-ami-${var.env}"
  }
}

