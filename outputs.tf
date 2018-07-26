output "alb_hostname" {
  value = "http://${aws_alb.front.dns_name}"
}

output "database_root_password" {
  value       = "${random_string.db_password.result}"
  sensitive   = true
  description = "Password for the root user of the RDS MySQL databse."
}

output "region" {
  value       = "${var.aws_region}"
  description = "Region the resources were created in."
}
