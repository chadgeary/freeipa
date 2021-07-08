resource "aws_cloudwatch_log_group" "freeipa-cloudwatch-log-group-ecs" {
  name              = "/aws/ecs/${var.name_prefix}_${random_string.freeipa-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.freeipa-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/ecs/${var.name_prefix}_${random_string.freeipa-random.result}"
  }
}

resource "aws_cloudwatch_log_group" "freeipa-cloudwatch-log-group-codebuild" {
  name              = "/aws/codebuild/${var.name_prefix}-codebuild-${random_string.freeipa-random.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.freeipa-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/codebuild/${var.name_prefix}-codebuild-${random_string.freeipa-random.result}"
  }
}
