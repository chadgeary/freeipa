resource "aws_kms_key" "freeipa-kmscmk-efs" {
  description              = "KMS CMK for EFS"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.name_prefix}-kmscmk-efs-${random_string.freeipa-random.result}"
  }
  policy = <<EOF
{
  "Id": "freeipa-kmscmk-efs",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable ECS Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.freeipa-ecs-role.arn}"
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
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.freeipa-aws-account.account_id}",
          "kms:ViaService": "ecs.${var.aws_region}.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Enable KMS Manager Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.freeipa-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "freeipa-kmscmk-efs-alias" {
  name          = "alias/${var.name_prefix}-kmscmk-efs-${random_string.freeipa-random.result}"
  target_key_id = aws_kms_key.freeipa-kmscmk-efs.key_id
}
