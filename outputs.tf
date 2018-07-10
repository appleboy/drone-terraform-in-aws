output "instance_security_group" {
  value = "${aws_security_group.ecs_tasks.id}"
}

output "elb_hostname" {
  value = "${aws_alb.main.dns_name}"
}
