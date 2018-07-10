resource "aws_vpc" "drone" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name        = "drone"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "drone_a" {
  vpc_id                  = "${aws_vpc.drone.id}"
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags {
    Name        = "drone_subset_a"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "drone_c" {
  vpc_id                  = "${aws_vpc.drone.id}"
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}c"

  tags {
    Name        = "drone_subset_c"
    Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "drone" {
  vpc_id = "${aws_vpc.drone.id}"

  tags {
    Name        = "drone_gw"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "drone" {
  vpc_id = "${aws_vpc.drone.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.drone.id}"
  }

  tags {
    Name        = "aws_route_table"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.drone_a.id}"
  route_table_id = "${aws_route_table.drone.id}"
}

resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.drone_c.id}"
  route_table_id = "${aws_route_table.drone.id}"
}
