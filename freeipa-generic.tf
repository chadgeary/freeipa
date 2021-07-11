variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "pubnet1_cidr" {
  type = string
}

variable "prinet1_cidr" {
  type = string
}

variable "pubnet2_cidr" {
  type = string
}

variable "prinet2_cidr" {
  type = string
}

variable "pubnet3_cidr" {
  type = string
}

variable "prinet3_cidr" {
  type = string
}

variable "client_cidrs" {
  type        = list(any)
  description = "Client CIDRs allowed to reach service"
}

variable "kms_manager" {
  type        = string
  description = "An IAM user for management of KMS key"
}

variable "name_prefix" {
  type        = string
  description = "A friendly name prefix for the AMI and EC2 instances, e.g. 'freeipa' or 'dev'"
}

variable "aws_default_tags" {
  type    = map(string)
  default = {}
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = var.aws_default_tags
  }
}

# region azs
data "aws_availability_zones" "freeipa-azs" {
  state = "available"
}

# account id
data "aws_caller_identity" "freeipa-aws-account" {
}

# kms cmk manager - granted read access to KMS CMKs
data "aws_iam_user" "freeipa-kmsmanager" {
  user_name = var.kms_manager
}

# aws, gov, or cn
data "aws_partition" "freeipa-aws-partition" {
}

# random string as suffix
resource "random_string" "freeipa-random" {
  length  = 5
  upper   = false
  special = false
}

variable "tcp_service_ports" {
  type    = list(any)
  default = []
}

variable "udp_service_ports" {
  type    = list(any)
  default = []
}

variable "tcpudp_service_ports" {
  type    = list(any)
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "freeipa_secret" {
  type = string
}

variable "ecs_cpu" {
  type = number
}

variable "ecs_memory" {
  type = number
}

variable "vendor_ami_account_number" {
  type = string
}

variable "vendor_ami_name_string" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_vol_size" {
  type = string
}

variable "minimum_node_count" {
  type = number
}

variable "maximum_node_count" {
  type = number
}

variable "ssh_key" {
  type = string
}
