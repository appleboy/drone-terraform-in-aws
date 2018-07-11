resource "aws_db_subnet_group" "db" {
  name       = "main"
  subnet_ids = ["${aws_subnet.drone_a.id}", "${aws_subnet.drone_c.id}"]

  tags {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "drone" {
  depends_on                = ["aws_security_group.db"]
  identifier                = "${var.identifier}"
  allocated_storage         = "${var.storage}"
  engine                    = "${var.engine}"
  engine_version            = "${lookup(var.engine_version, var.engine)}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.db_name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  vpc_security_group_ids    = ["${aws_security_group.db.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.db.id}"
  skip_final_snapshot       = true
  final_snapshot_identifier = "drone-${md5(timestamp())}"
  identifier                = "drone-${var.environment}"
}
