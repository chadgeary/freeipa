output "freeipa-output" {
  value = <<OUTPUT

# State Manager Association will show Status: Complete, then
# NLB Target Group will show Status: healthy

# NLB Target Group
https://console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#TargetGroup:targetGroupArn=${aws_lb_target_group.freeipa-mgmt-target-tcp.arn}

# Cloudwatch Logs
https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/$252Faws$252Fecs$252F${var.name_prefix}_${random_string.freeipa-random.result}

# NLB WebUI
https://${aws_lb.freeipa-node-nlb.dns_name}:${var.web_port}/nifi

OUTPUT
}
