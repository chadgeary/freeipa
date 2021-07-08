resource "aws_service_discovery_private_dns_namespace" "freeipa-svcnamespace" {
  name        = "${var.name_prefix}-${random_string.freeipa-random.result}.internal"
  description = "${var.name_prefix}-${random_string.freeipa-random.result}.internal Namespace"
  vpc         = aws_vpc.freeipa-vpc.id
}

resource "aws_service_discovery_service" "freeipa-svcdiscovery1" {
  name = "freeipa1"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.freeipa-svcnamespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "freeipa-svcdiscovery2" {
  name = "freeipa2"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.freeipa-svcnamespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "freeipa-svcdiscovery3" {
  name = "freeipa3"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.freeipa-svcnamespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
