resource "aws_ecs_cluster" "freeipa-ecs-cluster" {
  name               = "${var.name_prefix}-ecscluster-${random_string.freeipa-random.result}"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "freeipa-ecs-task" {
  for_each = toset(["1", "2", "3"])
  family   = "${var.name_prefix}-ecsservice${each.key}-${random_string.freeipa-random.result}"
  container_definitions = templatefile("freeipa-service${each.key}.tmpl",
    {
      name_prefix  = var.name_prefix
      aws_suffix   = random_string.freeipa-random.result
      aws_region   = var.aws_region
      aws_repo_url = aws_ecr_repository.freeipa-repo.repository_url
      secret_arn   = aws_ssm_parameter.freeipa-secret.arn
    }
  )
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.freeipa-ecs-role.arn
  execution_role_arn       = aws_iam_role.freeipa-ecs-role.arn
  volume {
    name = "service-storage"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.freeipa-efs-fs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.freeipa-efs-ap[each.key].id
        iam             = "ENABLED"
      }
    }
  }
  depends_on = [aws_iam_role_policy_attachment.freeipa-ecs-iam-attach-1]
}

resource "aws_ecs_service" "freeipa-ecs-service1" {
  name            = "${var.name_prefix}-ecs1-${random_string.freeipa-random.result}"
  cluster         = aws_ecs_cluster.freeipa-ecs-cluster.id
  task_definition = aws_ecs_task_definition.freeipa-ecs-task["1"].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.freeipa-prinet1.id]
    security_groups  = [aws_security_group.freeipa-prisg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.freeipa-svcdiscovery1.arn
  }
}

resource "aws_ecs_service" "freeipa-ecs-service2" {
  name            = "${var.name_prefix}-ecs2-${random_string.freeipa-random.result}"
  cluster         = aws_ecs_cluster.freeipa-ecs-cluster.id
  task_definition = aws_ecs_task_definition.freeipa-ecs-task["2"].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.freeipa-prinet2.id]
    security_groups  = [aws_security_group.freeipa-prisg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.freeipa-svcdiscovery2.arn
  }
}

resource "aws_ecs_service" "freeipa-ecs-service3" {
  name            = "${var.name_prefix}-ecs3-${random_string.freeipa-random.result}"
  cluster         = aws_ecs_cluster.freeipa-ecs-cluster.id
  task_definition = aws_ecs_task_definition.freeipa-ecs-task["3"].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.freeipa-prinet3.id]
    security_groups  = [aws_security_group.freeipa-prisg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.freeipa-svcdiscovery3.arn
  }
}
