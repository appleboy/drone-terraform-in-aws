output "elb_hostname" {
  value = "${aws_alb.front.dns_name}"
}
