output "alb_hostname" {
  value = "http://${aws_alb.front.dns_name}"
}
