resource "aws_kms_key" "freeipa-kmscmk-ec2" {
  description              = "Key for freeipa ami and ec2"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kmscmk-ec2-${random_string.freeipa-random.result}"
  }
  policy = <<EOF
{
  "Id": "freeipa-kmskeypolicy-ec2",
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
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
       "Service": "ec2.amazonaws.com"
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        },
        "StringEquals": {
          "kms:ViaService": ["ec2.${var.aws_region}.amazonaws.com"],
          "kms:CallerAccount": "${data.aws_caller_identity.freeipa-aws-account.account_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "freeipa-kmscmk-ec2-alias" {
  name          = "alias/${var.name_prefix}-ksmcmk-ec2-${random_string.freeipa-random.result}"
  target_key_id = aws_kms_key.freeipa-kmscmk-ec2.key_id
}
