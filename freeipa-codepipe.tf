resource "time_sleep" "wait_for_codepipe_deps" {
  create_duration = "30s"
  depends_on      = [aws_iam_role_policy_attachment.freeipa-codepipe-policy-role-attach, aws_ecs_task_definition.freeipa-ecs-task]
}

resource "aws_codepipeline" "freeipa-codepipe" {
  name     = "${var.name_prefix}-codepipe-${random_string.freeipa-random.result}"
  role_arn = aws_iam_role.freeipa-codepipe-role.arn
  artifact_store {
    location = aws_s3_bucket.freeipa-bucket.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.freeipa-kmscmk-s3.arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      output_artifacts = ["source_output"]
      version          = "1"
      configuration = {
        S3Bucket             = aws_s3_bucket.freeipa-bucket.bucket
        S3ObjectKey          = "freeipa-files/freeipa.zip"
        PollForSourceChanges = "Yes"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.freeipa-codebuild.name
      }
    }
  }
  depends_on = [time_sleep.wait_for_codepipe_deps]
}
