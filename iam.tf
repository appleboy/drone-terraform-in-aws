#
# ec2 instance iam rule
# drone server and agent
#
resource "aws_iam_role" "ecs_service" {
  name = "drone_ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service" {
  name = "drone_ecs_policy"
  role = "${aws_iam_role.ecs_service.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "template_file" "ecs_profile" {
  template = "${file("${path.module}/iam-policy/drone-ecs.json")}"

  vars {
    server_log_group_arn = "${aws_cloudwatch_log_group.drone_agent.arn}"
    agent_log_group_arn  = "${aws_cloudwatch_log_group.drone_server.arn}"
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "drone_ecs_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs" {
  name   = "drone-ecs-policy"
  role   = "${aws_iam_role.ecs_task.name}"
  policy = "${data.template_file.ecs_profile.rendered}"
}

#
# ec2 instance iam rule
# drone agent
#
resource "aws_iam_instance_profile" "drone" {
  name = "ecs-ec2-instprofile"
  role = "${aws_iam_role.drone_agent.name}"
}

resource "aws_iam_role" "drone_agent" {
  name = "ecs-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "template_file" "ec2_profile" {
  template = "${file("${path.module}/iam-policy/drone-ec2.json")}"

  vars {
    server_log_group_arn = "${aws_cloudwatch_log_group.drone_agent.arn}"
    agent_log_group_arn  = "${aws_cloudwatch_log_group.drone_server.arn}"
  }
}

resource "aws_iam_role_policy" "ec2" {
  name   = "drone-ec2-role"
  role   = "${aws_iam_role.drone_agent.name}"
  policy = "${data.template_file.ec2_profile.rendered}"
}
