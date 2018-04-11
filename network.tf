resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name    = "${var.project_name}"
    project = "${var.project_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name    = "${var.project_name}"
    project = "${var.project_name}"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags {
    Name        = "${var.project_name}_public_a"
    project     = "${var.project_name}"
    subnet_type = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name    = "${var.project_name}"
    project = "${var.project_name}"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1b"

  tags {
    Name        = "${var.project_name}_private_a"
    project     = "${var.project_name}"
    subnet_type = "private"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw_a" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_a.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw_a.id}"
  }

  tags {
    Name    = "${var.project_name}"
    project = "${var.project_name}"
  }
}

resource "aws_main_route_table_association" "nat" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_eip" "bar" {
  vpc      = true
  instance = "${aws_instance.machine.id}"
}
