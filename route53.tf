resource "aws_route53_zone" "primary" {
  name       = "${var.route53_zone}"
  comment    = "Zone for drone"
  vpc_id     = "${aws_vpc.drone.id}"
  vpc_region = "${var.aws_region}"

  tags {
    Name        = "drone domain"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "ns" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.route53_zone}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.primary.name_servers.0}",
    "${aws_route53_zone.primary.name_servers.1}",
    "${aws_route53_zone.primary.name_servers.2}",
    "${aws_route53_zone.primary.name_servers.3}",
  ]
}

resource "aws_route53_record" "drone" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "drone.${var.route53_zone}"
  type    = "A"

  alias {
    name                   = "${aws_alb.main.dns_name}"
    zone_id                = "${aws_alb.main.zone_id}"
    evaluate_target_health = true
  }
}
