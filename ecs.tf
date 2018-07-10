resource "aws_ecs_cluster" "drone" {
  name = "drone"
}

resource "aws_cloudwatch_log_group" "drone_server" {
  name = "drone/server"
}

resource "aws_cloudwatch_log_group" "drone_agent" {
  name = "drone/agent"
}

resource "aws_cloudwatch_log_group" "drone_db" {
  name = "drone/db"
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

  task_role_arn      = "${aws_iam_role.ecs_task.name}"
  execution_role_arn = "${aws_iam_role.ecs_task.name}"

  # execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"

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

  # iam_role        = "${aws_iam_role.foo.arn}"
  # depends_on      = ["aws_iam_role_policy.foo"]


  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }


  # load_balancer {
  #   target_group_arn = "${aws_lb_target_group.foo.arn}"
  #   container_name   = "mongo"
  #   container_port   = 8080
  # }


  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }

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
