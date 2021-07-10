resource "aws_efs_file_system" "freeipa-efs-fs" {
  creation_token = "${var.name_prefix}-efs-${random_string.freeipa-random.result}"
  encrypted      = "true"
  kms_key_id     = aws_kms_key.freeipa-kmscmk-efs.arn
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
}

resource "aws_efs_mount_target" "freeipa-efs-mount1" {
  file_system_id = aws_efs_file_system.freeipa-efs-fs.id
  security_groups = [aws_security_group.freeipa-prisg.id]
  subnet_id      = aws_subnet.freeipa-prinet1.id
}

resource "aws_efs_mount_target" "freeipa-efs-mount2" {
  file_system_id = aws_efs_file_system.freeipa-efs-fs.id
  security_groups = [aws_security_group.freeipa-prisg.id]
  subnet_id      = aws_subnet.freeipa-prinet2.id
}

resource "aws_efs_mount_target" "freeipa-efs-mount3" {
  file_system_id = aws_efs_file_system.freeipa-efs-fs.id
  security_groups = [aws_security_group.freeipa-prisg.id]
  subnet_id      = aws_subnet.freeipa-prinet3.id
}

resource "aws_efs_access_point" "freeipa-efs-ap" {
  for_each       = toset(["1", "2", "3"])
  file_system_id = aws_efs_file_system.freeipa-efs-fs.id
  root_directory {
    path = "/freeipa/${each.key}"
    creation_info {
      owner_gid   = 1
      owner_uid   = 1
      permissions = "700"
    }
  }
}
