# load balancer
resource "aws_lb" "freeipa-node-nlb" {
  name                             = "${var.name_prefix}-nlb-${random_string.freeipa-random.result}"
  subnets                          = [aws_subnet.freeipa-pubnet1.id, aws_subnet.freeipa-pubnet2.id, aws_subnet.freeipa-pubnet3.id]
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = "true"
  tags = {
    Name = "${var.name_prefix}-nlb-${random_string.freeipa-random.result}"
  }
}

resource "aws_lb_listener" "freeipa-service-listen-tcp" {
  count             = length(var.tcp_service_ports)
  port              = var.tcp_service_ports[count.index]
  protocol          = "TCP"
  load_balancer_arn = aws_lb.freeipa-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.freeipa-service-target-tcp[count.index].arn
  }
}

resource "aws_lb_listener" "freeipa-service-listen-udp" {
  count             = length(var.udp_service_ports)
  port              = var.udp_service_ports[count.index]
  protocol          = "UDP"
  load_balancer_arn = aws_lb.freeipa-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.freeipa-service-target-udp[count.index].arn
  }
}

resource "aws_lb_listener" "freeipa-service-listen-tcpudp" {
  count             = length(var.tcpudp_service_ports)
  port              = var.tcpudp_service_ports[count.index]
  protocol          = "TCP_UDP"
  load_balancer_arn = aws_lb.freeipa-node-nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.freeipa-service-target-tcpudp[count.index].arn
  }
}

resource "aws_lb_target_group" "freeipa-service-target-tcp" {
  count                = length(var.tcp_service_ports)
  port                 = var.tcp_service_ports[count.index]
  name                 = "${var.name_prefix}-tcp-${var.tcp_service_ports[count.index]}-${random_string.freeipa-random.result}"
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = aws_vpc.freeipa-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  health_check {
    enabled             = "true"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    interval            = 30
    protocol            = "TCP"
  }
}

resource "aws_lb_target_group" "freeipa-service-target-udp" {
  count                = length(var.udp_service_ports)
  port                 = var.udp_service_ports[count.index]
  name                 = "${var.name_prefix}-udp-${var.udp_service_ports[count.index]}-${random_string.freeipa-random.result}"
  protocol             = "UDP"
  target_type          = "ip"
  vpc_id               = aws_vpc.freeipa-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  health_check {
    enabled             = "true"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    interval            = 30
    port                = "443"
    protocol            = "TCP"
  }
}

resource "aws_lb_target_group" "freeipa-service-target-tcpudp" {
  count                = length(var.tcpudp_service_ports)
  port                 = var.tcpudp_service_ports[count.index]
  name                 = "${var.name_prefix}-tcpudp-${var.tcpudp_service_ports[count.index]}-${random_string.freeipa-random.result}"
  protocol             = "TCP_UDP"
  target_type          = "ip"
  vpc_id               = aws_vpc.freeipa-vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  health_check {
    enabled             = "true"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    interval            = 30
    protocol            = "TCP"
  }
}
