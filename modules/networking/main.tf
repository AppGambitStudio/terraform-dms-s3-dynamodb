/*====
The VPC
======*/

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

/*====
Subnets
======*/

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/*====
VPC's Default Security Group
======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Environment = "${var.environment}"
  }
}

