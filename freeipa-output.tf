output "freeipa-output" {
  value = <<OUTPUT

# Cloudwatch Logs
https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/$252Faws$252Fecs$252F${var.name_prefix}_${random_string.freeipa-random.result}

# NLB WebUI
https://${aws_lb.freeipa-node-nlb.dns_name}

OUTPUT
}
