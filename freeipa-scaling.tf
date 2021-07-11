# tags
locals {
  node-asg-tags = [
    {
      key                 = "Name"
      value               = "node.${var.name_prefix}-${random_string.freeipa-random.result}.internal"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.name_prefix}-${random_string.freeipa-random.result}"
      propagate_at_launch = true
    },
    {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    }
  ]
}

# ssh
resource "aws_key_pair" "freeipa-ssh-key" {
  key_name                = "${var.name_prefix}-ssh-key-${random_string.freeipa-random.result}"
  public_key              = var.ssh_key
  tags                    = {
    Name                    = "${var.name_prefix}-ssh-key-${random_string.freeipa-random.result}"
  }
}

# launch conf
resource "aws_launch_configuration" "freeipa-launchconf" {
  name_prefix          = "${var.name_prefix}-lconf-${random_string.freeipa-random.result}-"
  image_id             = aws_ami_copy.freeipa-encrypted-ami.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.freeipa-ssh-key.key_name
  iam_instance_profile = aws_iam_instance_profile.freeipa-instance-profile.name
  security_groups      = [aws_security_group.freeipa-prisg.id]
  root_block_device {
    volume_size = var.instance_vol_size
    volume_type = "standard"
    encrypted   = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<EOF
#!/bin/bash
# set fqdn 
hostnamectl set-hostname $(hostname).${var.name_prefix}-${random_string.freeipa-random.result}.internal
EOF
}

# autoscaling group
resource "aws_autoscaling_group" "freeipa-autoscalegroup" {
  name_prefix               = "${var.name_prefix}-asg-${random_string.freeipa-random.result}-"
  launch_configuration      = aws_launch_configuration.freeipa-launchconf.name
  vpc_zone_identifier       = [aws_subnet.freeipa-prinet1.id, aws_subnet.freeipa-prinet2.id, aws_subnet.freeipa-prinet3.id]
  termination_policies      = ["ClosestToNextInstanceHour"]
  min_size                  = var.minimum_node_count
  max_size                  = var.maximum_node_count
  health_check_type         = "EC2"
  health_check_grace_period = 1800
  lifecycle {
    create_before_destroy = true
  }
  dynamic "tag" {
    for_each = local.node-asg-tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  depends_on = [aws_iam_role_policy_attachment.freeipa-ec2-iam-attach-1, aws_iam_role_policy_attachment.freeipa-ec2-iam-attach-2]
}

resource "aws_ecs_capacity_provider" "freeipa-ecs-provider" {
  name = "${var.name_prefix}-ecs-provider-${random_string.freeipa-random.result}"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.freeipa-autoscalegroup.arn
    managed_termination_protection = "ENABLED"
    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}
