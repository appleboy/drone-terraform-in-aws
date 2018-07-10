resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${aws_vpc.drone.id}"
  name   = "tf-ecs-lbsg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "ecs_tasks" {
  description = "controls direct access to application instances"
  vpc_id      = "${aws_vpc.drone.id}"
  name        = "ecs-task"

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 8000
    to_port   = 8000

    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_ecs_cluster" "drone" {
  name = "drone"
}

resource "aws_ebs_volume" "drone" {
  availability_zone = "${var.aws_region}a"
  size              = 10

  tags {
    Name = "drone"
  }
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
    volume                 = "${aws_ebs_volume.drone.id}"
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
  volume {
    name = "${aws_ebs_volume.drone.id}"

    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html
    # Fargate currently supports non-persistent, empty data volumes for containers. When you define your container, you no longer use the host field and only specify a name.
    # see https://aws.amazon.com/tw/blogs/compute/migrating-your-amazon-ecs-containers-to-aws-fargate/
    # host_path = "/var/lib/drone"
  }
}

resource "aws_ecs_service" "drone" {
  name            = "drone"
  cluster         = "${aws_ecs_cluster.drone.id}"
  task_definition = "${aws_ecs_task_definition.drone.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  # iam_role        = "${aws_iam_role.ecs_service.name}"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
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
    "aws_alb_listener.front_end",
  ]
}
