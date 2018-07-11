resource "aws_alb_target_group" "drone" {
  name        = "drone-ecs"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.drone.id}"
  target_type = "ip"

  health_check {
    path                = "/healthz"
    matcher             = "200"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb" "front" {
  name            = "drone-front-alb"
  internal        = false
  security_groups = ["${aws_security_group.web.id}"]
  subnets         = ["${aws_subnet.drone_a.id}", "${aws_subnet.drone_c.id}"]

  enable_deletion_protection = false

  tags {
    Name        = "drone"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "front_end_80" {
  load_balancer_arn = "${aws_alb.front.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.drone.id}"
    type             = "forward"
  }
}
