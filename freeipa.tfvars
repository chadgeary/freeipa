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

# the subnet(s) permitted to browse nifi (port 2170 or web_port) via the AWS NLB
mgmt_cidrs = ["127.0.0.0/32"]

# the subnet(s) permitted to send traffic to service ports
client_cidrs = []

# management port for HTTPS via NLB
web_port = 443

# service ports for traffic inbound via NLB
tcp_service_ports    = [636]
udp_service_ports    = []
tcpudp_service_ports = [88, 464]

# public ssh key
instance_key = "ssh-rsa AAAAB3NzaD2yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu2gya2wMLeo1rBJ5cbZZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6sPAltLaOUONn0SF2BvvJUueqxpAIaA2rU4MS420P"

# size according to workloads with at least 2GB of RAM (which is barely enough).
instance_type = "t3a.medium"

# the root block size of the instances (in GiB)
instance_vol_size = 20

# the initial size (min) and max count of nodes.
# scale is based on CPU load
minimum_node_count = 1
maximum_node_count = 1

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
