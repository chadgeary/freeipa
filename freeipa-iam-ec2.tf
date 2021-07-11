resource "aws_iam_role" "freeipa-ec2-role" {
  name               = "${var.name_prefix}-ec2role-${random_string.freeipa-random.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "EC2"
    }
  ]
}
EOF
}

data "aws_iam_policy" "freeipa-ec2-policy-ssm" {
  arn = "arn:${data.aws_partition.freeipa-aws-partition.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "freeipa-ec2-policy-etc" {
  name   = "${var.name_prefix}-ec2-policy-${random_string.freeipa-random.result}"
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
        "logs:PutLogEvents"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "freeipa-ec2-iam-attach-1" {
  role       = aws_iam_role.freeipa-ec2-role.name
  policy_arn = data.aws_iam_policy.freeipa-ec2-policy-ssm.arn
}

resource "aws_iam_role_policy_attachment" "freeipa-ec2-iam-attach-2" {
  role       = aws_iam_role.freeipa-ec2-role.name
  policy_arn = aws_iam_policy.freeipa-ec2-policy-etc.arn
}

resource "aws_iam_instance_profile" "freeipa-instance-profile" {
  name = "${var.name_prefix}-instance-profile-${random_string.freeipa-random.result}"
  role = aws_iam_role.freeipa-ec2-role.name
}
