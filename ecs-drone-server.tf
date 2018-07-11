resource "aws_ecs_cluster" "drone" {
  name = "drone"
}

data "template_file" "drone_server_task_definition" {
  template = "${file("${path.module}/task-definitions/drone-server.json")}"

  vars {
    db_name                = "${aws_db_instance.drone.address}"
    db_user                = "${var.username}"
    db_password            = "${var.password}"
    log_group_region       = "${var.aws_region}"
    log_group_drone_server = "${aws_cloudwatch_log_group.drone_server.name}"
  }
}

resource "aws_ecs_task_definition" "drone_server" {
  family                   = "drone-server"
  container_definitions    = "${data.template_file.drone_server_task_definition.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  task_role_arn      = "${aws_iam_role.ecs_task.arn}"
  execution_role_arn = "${aws_iam_role.ecs_task.arn}"

  cpu    = "512"
  memory = "2048"
}

resource "aws_ecs_service" "drone_server" {
  name            = "drone-server"
  cluster         = "${aws_ecs_cluster.drone.id}"
  task_definition = "${aws_ecs_task_definition.drone_server.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  # iam_role        = "${aws_iam_role.ecs_service.name}"

  network_configuration {
    security_groups  = ["${aws_security_group.drone_server.id}"]
    subnets          = ["${aws_subnet.drone_a.id}", "${aws_subnet.drone_c.id}"]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.drone.id}"
    container_name   = "drone-server"
    container_port   = "8000"
  }
  depends_on = [
    # "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end_80",
  ]
}
