resource "aws_alb_target_group" "drone" {
  name        = "drone-ecs"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.drone.id}"
  target_type = "ip"
}

resource "aws_alb" "main" {
  name            = "drone-ecs"
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${aws_subnet.drone_a.id}", "${aws_subnet.drone_c.id}"]

  enable_deletion_protection = false

  tags {
    Name        = "drone"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.drone.id}"
    type             = "forward"
  }
}
