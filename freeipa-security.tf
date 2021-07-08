resource "aws_security_group" "freeipa-prisg" {
  name        = "${var.name_prefix}-sg-freeipa-${random_string.freeipa-random.result}"
  description = "Security group for ${var.name_prefix} ${random_string.freeipa-random.result}"
  vpc_id      = aws_vpc.freeipa-vpc.id
  tags = {
    Name = "${var.name_prefix}-sg-freeipa-${random_string.freeipa-random.result}"
  }
}

# self
resource "aws_security_group_rule" "freeipa-sg-freeipa-intcp" {
  for_each                 = toset(["80", "443", "389", "636", "88", "464"])
  security_group_id        = aws_security_group.freeipa-prisg.id
  type                     = "ingress"
  description              = "IN FROM SELF TCP ${each.key}"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.freeipa-prisg.id
}

resource "aws_security_group_rule" "freeipa-sg-freeipa-inudp" {
  for_each                 = toset(["88", "464"])
  security_group_id        = aws_security_group.freeipa-prisg.id
  type                     = "ingress"
  description              = "IN FROM SELF UDP ${each.key}"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "udp"
  source_security_group_id = aws_security_group.freeipa-prisg.id
}

resource "aws_security_group_rule" "freeipa-sg-freeipa-outtcp" {
  for_each                 = toset(["80", "443", "389", "636", "88", "464"])
  security_group_id        = aws_security_group.freeipa-prisg.id
  type                     = "egress"
  description              = "OUT FROM SELF TCP ${each.key}"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.freeipa-prisg.id
}

resource "aws_security_group_rule" "freeipa-sg-freeipa-outudp" {
  for_each                 = toset(["88", "464"])
  security_group_id        = aws_security_group.freeipa-prisg.id
  type                     = "egress"
  description              = "OUT FROM SELF UDP ${each.key}"
  from_port                = each.key
  to_port                  = each.key
  protocol                 = "udp"
  source_security_group_id = aws_security_group.freeipa-prisg.id
}

# world
resource "aws_security_group_rule" "freeipa-prisg-tcp-out" {
  security_group_id = aws_security_group.freeipa-prisg.id
  type              = "egress"
  description       = "OUT TO WORLD - TCP"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "freeipa-prisg-udp-out" {
  security_group_id = aws_security_group.freeipa-prisg.id
  type              = "egress"
  description       = "OUT TO WORLD - UDP"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}
