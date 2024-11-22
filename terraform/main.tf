provider "aws" {
  region = var.aws_region
}

locals {
  acct_map = {for acct in var.allowed_accounts : acct => var.volume_ids}
}

# Create our CMK
resource "aws_kms_key" "customer_managed_key" {
  description             = "Customer managed key for EBS snapshot encryption"
  deletion_window_in_days = 7

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "kms-key-policy",
  "Statement": [
    {
      "Sid": "EnableRootAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "AllowOtherAccountsUsage",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(var.allowed_accounts)}
      },
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# Give our key a name
resource "aws_kms_alias" "name" {
  name          = "alias/old-env-ebs"
  target_key_id = aws_kms_key.customer_managed_key.key_id
}

data "aws_caller_identity" "current" {}

# Create a snapshot encrypted with the KMS key
resource "aws_ebs_snapshot" "source" {
  count = length(var.volume_ids)
  volume_id  = var.volume_ids[count.index]

  tags = {
    Name = "Source snapshot of ${var.volume_ids[count.index]}"
  }

  timeouts {
    create = "6h"
    delete = "1h"
  }

}

resource "aws_ebs_snapshot_copy" "final" {
  count = length(aws_ebs_snapshot.source)
  source_snapshot_id = aws_ebs_snapshot.source[count.index].id
  source_region      = var.aws_region # TODO: West to east
  encrypted          = true
  kms_key_id         = aws_kms_key.customer_managed_key.arn

  tags = {
    Name = "Copied EBS Snapshot with New KMS Key for ${var.volume_ids[count.index]}"
  }

  timeouts {
    create = "6h"
    delete = "1h"
  }
}

module "snapshot_vol_perms" {
  count       = length(var.volume_ids)
  source      = "./create_vol_perms"
  snapshot_id = aws_ebs_snapshot_copy.final[count.index].id
  account_ids = var.allowed_accounts
}