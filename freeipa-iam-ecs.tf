resource "aws_iam_role" "freeipa-ecs-role" {
  name               = "${var.name_prefix}-ecsrole-${random_string.freeipa-random.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "ECS"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "freeipa-ecs-policy" {
  name   = "${var.name_prefix}-ecs-policy-${random_string.freeipa-random.result}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ssm:DescribeParameters",
        "kms:ListKeys"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${aws_efs_file_system.freeipa-efs-fs.arn}"
      ],
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Condition": {
        "StringEquals": {
          "elasticfilesystem:AccessPointArn":["${aws_efs_access_point.freeipa-efs-ap[1].arn}","${aws_efs_access_point.freeipa-efs-ap[2].arn}","${aws_efs_access_point.freeipa-efs-ap[3].arn}"]
        }
      }
    },
    {
      "Sid": "SSMKMSCMK",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.freeipa-kmscmk-ssm.arn}"]
    },
    {
      "Sid": "SSMParameter",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": ["${aws_ssm_parameter.freeipa-secret.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "freeipa-ecs-iam-attach-1" {
  role       = aws_iam_role.freeipa-ecs-role.name
  policy_arn = aws_iam_policy.freeipa-ecs-policy.arn
}
