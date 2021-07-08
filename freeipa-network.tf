# vpc and gateway
resource "aws_vpc" "freeipa-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.name_prefix}-vpc-${random_string.freeipa-random.result}"
  }
}

# route53 domain
resource "aws_vpc_dhcp_options" "freeipa-dhcp-opts" {
  domain_name         = "${var.name_prefix}-${random_string.freeipa-random.result}.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "freeipa-dhcp-assoc" {
  vpc_id          = aws_vpc.freeipa-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.freeipa-dhcp-opts.id
}

# internet gateway for public subnets
resource "aws_internet_gateway" "freeipa-gw" {
  vpc_id = aws_vpc.freeipa-vpc.id
  tags = {
    Name = "${var.name_prefix}-ig-${random_string.freeipa-random.result}"
  }
}

# elastic ips for nat gateways
resource "aws_eip" "freeipa-ng-eip1" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-eip-1-${random_string.freeipa-random.result}"
  }
}

resource "aws_eip" "freeipa-ng-eip2" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-eip-2-${random_string.freeipa-random.result}"
  }
}

resource "aws_eip" "freeipa-ng-eip3" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-eip-3-${random_string.freeipa-random.result}"
  }
}

# nat gateways per public subnet for private subnets
resource "aws_nat_gateway" "freeipa-ng1" {
  allocation_id = aws_eip.freeipa-ng-eip1.id
  subnet_id     = aws_subnet.freeipa-pubnet1.id
  tags = {
    Name = "${var.name_prefix}-ng-1-${random_string.freeipa-random.result}"
  }
  depends_on = [aws_internet_gateway.freeipa-gw]
}

resource "aws_nat_gateway" "freeipa-ng2" {
  allocation_id = aws_eip.freeipa-ng-eip2.id
  subnet_id     = aws_subnet.freeipa-pubnet2.id
  tags = {
    Name = "${var.name_prefix}-ng-2-${random_string.freeipa-random.result}"
  }
  depends_on = [aws_internet_gateway.freeipa-gw]
}

resource "aws_nat_gateway" "freeipa-ng3" {
  allocation_id = aws_eip.freeipa-ng-eip3.id
  subnet_id     = aws_subnet.freeipa-pubnet3.id
  tags = {
    Name = "${var.name_prefix}-ng-3-${random_string.freeipa-random.result}"
  }
  depends_on = [aws_internet_gateway.freeipa-gw]
}

# public route table
resource "aws_route_table" "freeipa-pubrt" {
  vpc_id = aws_vpc.freeipa-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.freeipa-gw.id
  }
  tags = {
    Name = "${var.name_prefix}-pub-rt-${random_string.freeipa-random.result}"
  }
}

# private route tables
resource "aws_route_table" "freeipa-prirt1" {
  vpc_id = aws_vpc.freeipa-vpc.id
  tags = {
    Name = "${var.name_prefix}-pri-rt-1-${random_string.freeipa-random.result}"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.freeipa-ng1.id
  }
}

resource "aws_route_table" "freeipa-prirt2" {
  vpc_id = aws_vpc.freeipa-vpc.id
  tags = {
    Name = "${var.name_prefix}-pri-rt-2-${random_string.freeipa-random.result}"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.freeipa-ng2.id
  }
}

resource "aws_route_table" "freeipa-prirt3" {
  vpc_id = aws_vpc.freeipa-vpc.id
  tags = {
    Name = "${var.name_prefix}-pri-rt-3-${random_string.freeipa-random.result}"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.freeipa-ng3.id
  }
}

# public subnets
resource "aws_subnet" "freeipa-pubnet1" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  availability_zone = data.aws_availability_zones.freeipa-azs.names[0]
  cidr_block        = var.pubnet1_cidr
  tags = {
    Name = "${var.name_prefix}-pub-net-1-${random_string.freeipa-random.result}"
  }
}

resource "aws_subnet" "freeipa-pubnet2" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  availability_zone = data.aws_availability_zones.freeipa-azs.names[1]
  cidr_block        = var.pubnet2_cidr
  tags = {
    Name = "${var.name_prefix}-pub-net-2-${random_string.freeipa-random.result}"
  }
}

resource "aws_subnet" "freeipa-pubnet3" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  availability_zone = data.aws_availability_zones.freeipa-azs.names[2]
  cidr_block        = var.pubnet3_cidr
  tags = {
    Name = "${var.name_prefix}-pub-net-3-${random_string.freeipa-random.result}"
  }
}

# private subnets
resource "aws_subnet" "freeipa-prinet1" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  availability_zone = data.aws_availability_zones.freeipa-azs.names[0]
  cidr_block        = var.prinet1_cidr
  tags = {
    Name = "${var.name_prefix}-pri-net-1-${random_string.freeipa-random.result}"
  }
}

resource "aws_subnet" "freeipa-prinet2" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  availability_zone = data.aws_availability_zones.freeipa-azs.names[1]
  cidr_block        = var.prinet2_cidr
  tags = {
    Name = "${var.name_prefix}-pri-net-2-${random_string.freeipa-random.result}"
  }
}

resource "aws_subnet" "freeipa-prinet3" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  availability_zone = data.aws_availability_zones.freeipa-azs.names[2]
  cidr_block        = var.prinet3_cidr
  tags = {
    Name = "${var.name_prefix}-pri-net-3-${random_string.freeipa-random.result}"
  }
}

# public route table associations
resource "aws_route_table_association" "rt-assoc-pubnet1" {
  subnet_id      = aws_subnet.freeipa-pubnet1.id
  route_table_id = aws_route_table.freeipa-pubrt.id
}

resource "aws_route_table_association" "rt-assoc-pubnet2" {
  subnet_id      = aws_subnet.freeipa-pubnet2.id
  route_table_id = aws_route_table.freeipa-pubrt.id
}

resource "aws_route_table_association" "rt-assoc-pubnet3" {
  subnet_id      = aws_subnet.freeipa-pubnet3.id
  route_table_id = aws_route_table.freeipa-pubrt.id
}

# private route table associations
resource "aws_route_table_association" "rt-assoc-prinet1" {
  subnet_id      = aws_subnet.freeipa-prinet1.id
  route_table_id = aws_route_table.freeipa-prirt1.id
}

resource "aws_route_table_association" "rt-assoc-prinet2" {
  subnet_id      = aws_subnet.freeipa-prinet2.id
  route_table_id = aws_route_table.freeipa-prirt2.id
}

resource "aws_route_table_association" "rt-assoc-prinet3" {
  subnet_id      = aws_subnet.freeipa-prinet3.id
  route_table_id = aws_route_table.freeipa-prirt3.id
}

# s3 endpoint for private instance(s)
resource "aws_vpc_endpoint" "freeipa-s3-endpoint" {
  vpc_id            = aws_vpc.freeipa-vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.freeipa-prirt1.id, aws_route_table.freeipa-prirt2.id, aws_route_table.freeipa-prirt3.id]
  tags = {
    Name = "${var.name_prefix}-s3-endpoint-${random_string.freeipa-random.result}"
  }
}

data "aws_prefix_list" "freeipa-s3-prefixlist" {
  prefix_list_id = aws_vpc_endpoint.freeipa-s3-endpoint.prefix_list_id
}
