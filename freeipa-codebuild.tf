resource "aws_codebuild_project" "freeipa-codebuild" {
  name           = "${var.name_prefix}-codebuild-${random_string.freeipa-random.result}"
  description    = "Codebuild for CodePipe to ECS"
  build_timeout  = "10"
  service_role   = aws_iam_role.freeipa-codebuild-role.arn
  encryption_key = aws_kms_key.freeipa-kmscmk-code.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  # https://github.com/hashicorp/terraform-provider-aws/issues/10195
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "true"
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.freeipa-aws-account.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.freeipa-repo.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
  source {
    type = "CODEPIPELINE"
  }
  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.freeipa-bucket.id}/build-log"
    }
  }
  vpc_config {
    vpc_id             = aws_vpc.freeipa-vpc.id
    subnets            = [aws_subnet.freeipa-prinet1.id, aws_subnet.freeipa-prinet2.id, aws_subnet.freeipa-prinet3.id]
    security_group_ids = [aws_security_group.freeipa-prisg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.freeipa-codebuild-policy-role-attach, aws_cloudwatch_log_group.freeipa-cloudwatch-log-group-codebuild, aws_s3_bucket_object.freeipa-s3-codebuild-object]
}
