resource "aws_ecs_cluster" "drone" {
  name = "drone"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definitions/service.json")}"

  vars {
    log_group_region       = "${var.aws_region}"
    log_group_drone_server = "${aws_cloudwatch_log_group.drone_server.name}"
    log_group_drone_agent  = "${aws_cloudwatch_log_group.drone_agent.name}"
    log_group_drone_db     = "${aws_cloudwatch_log_group.drone_db.name}"
  }
}

resource "aws_ecs_task_definition" "drone" {
  family                   = "drone-service"
  container_definitions    = "${data.template_file.task_definition.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  task_role_arn      = "${aws_iam_role.ecs_task.arn}"
  execution_role_arn = "${aws_iam_role.ecs_task.arn}"

  cpu    = "512"
  memory = "4096"
}

resource "aws_ecs_service" "drone" {
  name            = "drone"
  cluster         = "${aws_ecs_cluster.drone.id}"
  task_definition = "${aws_ecs_task_definition.drone.arn}"
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
