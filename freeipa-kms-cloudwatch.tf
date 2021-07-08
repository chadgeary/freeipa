resource "aws_kms_key" "freeipa-kmscmk-cloudwatch" {
  description              = "Key for freeipa cloudwatch"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kms-cloudwatch-${random_string.freeipa-random.result}"
  }
  policy = <<EOF
{
  "Id": "freeipa-kmskeypolicy-cloudwatch",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.freeipa-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access through cloudwatch",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "ArnEquals": {
          "kms:EncryptionContext:aws:logs:arn": ["arn:${data.aws_partition.freeipa-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.freeipa-aws-account.account_id}:log-group:/aws/ecs/${var.name_prefix}_${random_string.freeipa-random.result}","arn:${data.aws_partition.freeipa-aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.freeipa-aws-account.account_id}:log-group:/aws/codebuild/${var.name_prefix}-codebuild-${random_string.freeipa-random.result}"]
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "freeipa-kmscmk-cloudwatch-alias" {
  name          = "alias/${var.name_prefix}-kms-cloudwatch-${random_string.freeipa-random.result}"
  target_key_id = aws_kms_key.freeipa-kmscmk-cloudwatch.key_id
}
