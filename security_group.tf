resource "aws_security_group" "web" {
  description = "controls access to the application ELB"

  vpc_id = "${aws_vpc.drone.id}"
  name   = "drone-lb"

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

resource "aws_security_group" "drone_server" {
  description = "controls direct access to application instances"
  vpc_id      = "${aws_vpc.drone.id}"
  name        = "drone-server-task-sg"

  ingress {
    protocol  = "tcp"
    from_port = 8000
    to_port   = 8000

    security_groups = [
      "${aws_security_group.web.id}",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 9000
    to_port   = 9000

    security_groups = [
      "${aws_security_group.ec2_sg.id}",
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

resource "aws_security_group" "db" {
  name        = "drone-db-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.drone.id}"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "TCP"

    security_groups = [
      "${aws_security_group.drone_server.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${aws_vpc.drone.id}"
  name        = "ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
