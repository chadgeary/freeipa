# secret
resource "aws_ssm_parameter" "freeipa-secret" {
  name   = "${var.name_prefix}-freeipa-secret-${random_string.freeipa-random.result}"
  type   = "SecureString"
  key_id = aws_kms_key.freeipa-kmscmk-ssm.key_id
  value  = var.freeipa_secret
}
