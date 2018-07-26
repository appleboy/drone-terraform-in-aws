output "alb_hostname" {
  value = "http://${aws_alb.front.dns_name}"
}

output "db_password" {
  value = "db password is ${random_string.db_password.result}"
}
