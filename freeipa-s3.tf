resource "aws_s3_bucket" "freeipa-bucket" {
  bucket = "${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.freeipa-kmscmk-s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  force_destroy = true
  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KMS Manager",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${data.aws_iam_user.freeipa-kmsmanager.arn}"]
      },
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:${data.aws_partition.freeipa-aws-partition.partition}:s3:::${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}",
        "arn:${data.aws_partition.freeipa-aws-partition.partition}:s3:::${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}/*"
      ]
    },
    {
      "Sid": "Codepipe",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.freeipa-codepipe-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL"
      ],
      "Resource": ["arn:${data.aws_partition.freeipa-aws-partition.partition}:s3:::${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}","arn:${data.aws_partition.freeipa-aws-partition.partition}:s3:::${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}/*"]
    },
    {
      "Sid": "Codebuild",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${aws_iam_role.freeipa-codebuild-role.arn}"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectACL"
      ],
      "Resource": ["arn:${data.aws_partition.freeipa-aws-partition.partition}:s3:::${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}","arn:${data.aws_partition.freeipa-aws-partition.partition}:s3:::${var.name_prefix}-freeipa-bucket-${random_string.freeipa-random.result}/*"]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "freeipa-bucket-pub-access" {
  bucket                  = aws_s3_bucket.freeipa-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
