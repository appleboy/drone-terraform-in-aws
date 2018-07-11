resource "aws_service_discovery_private_dns_namespace" "drone" {
  name        = "drone.local"
  description = "drone private dns"
  vpc         = "${aws_vpc.drone.id}"
}

resource "aws_service_discovery_service" "drone_server" {
  name = "server"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.drone.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 10
  }
}
