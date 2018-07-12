resource "aws_autoscaling_group" "drone_agent" {
  name                 = "drone-agent"
  vpc_zone_identifier  = ["${aws_subnet.drone_a.id}", "${aws_subnet.drone_c.id}"]
  min_size             = "1"
  max_size             = "3"
  desired_capacity     = "2"
  launch_configuration = "${aws_launch_configuration.app.name}"
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars {
    ecs_cluster_name = "${aws_ecs_cluster.drone.name}"
  }
}

data "aws_ami" "stable_coreos" {
  filter {
    name   = "image-id"
    values = ["${lookup(var.amis, var.aws_region)}"]
  }
}

resource "aws_launch_configuration" "app" {
  security_groups = [
    "${aws_security_group.ec2_sg.id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.stable_coreos.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.drone.name}"
  user_data                   = "${data.template_file.cloud_config.rendered}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}
