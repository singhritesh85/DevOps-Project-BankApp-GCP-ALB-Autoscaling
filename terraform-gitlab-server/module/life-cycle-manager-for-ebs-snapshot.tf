############################################# Lifecycle Manager to create Snapshot of Volume ##############################################

resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "dlm-lifecycle-role"
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
  name   = "dlm-lifecycle-policy"
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
        ],
        "Effect": "Allow",
        "Resource": ["*"]
      },
      {
        "Action": [
          "ec2:CreateTags"
        ],
        "Effect": "Allow",
        "Resource": ["arn:aws:ec2:*::snapshot/*"]
      }
    ]
  })
}

resource "aws_dlm_lifecycle_policy" "ebs_lifecycle" {
  description        = "DLM lifecycle policy for EBS"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]
    policy_type    = "EBS_SNAPSHOT_MANAGEMENT"

    schedule {
      name = "daily snapshots to be kept for 30 days"

      create_rule {
        interval      = 12
        interval_unit = "HOURS"
        times         = ["11:00"]  ### First Snapshot will be created at 11 O'clock UTC in night and the 11 O'clock UTC in the morning.
      }

      retain_rule {
        count = 60    ### Keep last 60 copies which is last 30 days of snapshot before descard it.
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true  ### Do you want to copy tags from the source EBS to the snapshots.
    }

    target_tags = {
      Snapshot = "true" ### This tags should be present in the EBS of the EC2 which snapshot to be created.
    }
    
  }
  tags = {
    Name = "lifecycle-policy-ebs-${var.env}"
  }
}

