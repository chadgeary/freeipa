resource "aws_ecr_repository" "freeipa-repo" {
  name                 = "${var.name_prefix}-repo-${random_string.freeipa-random.result}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.freeipa-kmscmk-ecr.arn
  }
}
