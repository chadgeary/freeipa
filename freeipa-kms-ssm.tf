resource "aws_kms_key" "freeipa-kmscmk-ssm" {
  description              = "Key for freeipa ssm"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kmscmk-ssm-${random_string.freeipa-random.result}"
  }
  policy = <<EOF
{
  "Id": "freeipa-kmskeypolicy-ssm",
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
      "Sid": "Allow access through ecs",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.freeipa-ecs-role.arn}"
      },
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.freeipa-aws-account.account_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "freeipa-kmscmk-ssm-alias" {
  name          = "alias/${var.name_prefix}-ksmcmk-ssm-${random_string.freeipa-random.result}"
  target_key_id = aws_kms_key.freeipa-kmscmk-ssm.key_id
}
