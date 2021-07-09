# aws profile (e.g. from aws configure, usually "default")
aws_profile = "default"
aws_region  = "us-east-1"

# existing aws iam user granted access to the kms key (for browsing KMS encrypted services like S3 or SNS).
kms_manager = "some_iam_user"

# passphrase for various encrypted services
freeipa_secret = "changeme"

# additional aws tags
aws_default_tags = {
  Environment = "Development"
}

# the subnet(s) permitted to send traffic to service ports
client_cidrs = ["127.0.0.1/32"]

# management port for HTTPS via NLB
web_port = 443

# service ports for traffic inbound via NLB
tcp_service_ports    = [80, 443, 389, 636]
udp_service_ports    = []
tcpudp_service_ports = [88, 464]

# the name prefix for various resources
name_prefix = "id1"

# days to retain logs in cloudwatch
log_retention_days = 30

# vpc specific vars, modify these values if there would be overlap with existing resources.
vpc_cidr     = "10.10.14.0/24"
pubnet1_cidr = "10.10.14.0/28"
pubnet2_cidr = "10.10.14.16/28"
pubnet3_cidr = "10.10.14.32/28"
prinet1_cidr = "10.10.14.64/26"
prinet2_cidr = "10.10.14.128/26"
prinet3_cidr = "10.10.14.192/26"

# Container CPU and Memory
ecs_cpu    = 256
ecs_memory = 512
