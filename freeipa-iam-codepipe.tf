resource "aws_iam_policy" "freeipa-codepipe-policy" {
  name   = "${var.name_prefix}-codepipe-policy-${random_string.freeipa-random.result}"
  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": ["arn:aws:iam::*:role/${var.name_prefix}-codepipe-${random_string.freeipa-random.result}"],
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "codepipeline.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "${aws_codebuild_project.freeipa-codebuild.arn}",
            "Effect": "Allow"
        },
        {
            "Sid": "ObjectsinBucketPrefix",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject"
            ],
            "Resource": ["${aws_s3_bucket.freeipa-bucket.arn}","${aws_s3_bucket.freeipa-bucket.arn}/*"]
        },
        {
            "Sid": "CodeKMSCMK",
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": ["${aws_kms_key.freeipa-kmscmk-code.arn}"]
        },
        {
            "Sid": "S3KMSCMK",
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:ReEncrypt*",
                "kms:Decrypt",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": ["${aws_kms_key.freeipa-kmscmk-s3.arn}"]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "freeipa-codepipe-role" {
  name               = "${var.name_prefix}-codepipe-${random_string.freeipa-random.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "Codepipeline"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "freeipa-codepipe-policy-role-attach" {
  role       = aws_iam_role.freeipa-codepipe-role.name
  policy_arn = aws_iam_policy.freeipa-codepipe-policy.arn
}
