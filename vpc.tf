resource "aws_vpc" "website-vpc" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = "${var.aws_vpc_cidr_block}"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = false
  enable_dns_support               = true
  instance_tenancy                 = "default"

  tags = {
    Name = "website-vpc"
  }
}

resource "aws_internet_gateway" "website-igw" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  tags = {
    Name = "website-igw"
  }
}

resource "aws_subnet" "website-subnet-public-a" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  assign_ipv6_address_on_creation = false
  availability_zone               = "${element(var.aws_region_azs, 0)}"
  cidr_block                      = "${var.aws_vpc_subnet_cidrs["public-a"]}"
  map_public_ip_on_launch         = true

  tags = {
    Name = "website-subnet-public-a"
  }
}

resource "aws_subnet" "website-subnet-public-b" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  assign_ipv6_address_on_creation = false
  availability_zone               = "${element(var.aws_region_azs, 1)}"
  cidr_block                      = "${var.aws_vpc_subnet_cidrs["public-b"]}"
  map_public_ip_on_launch         = true

  tags = {
    Name = "website-subnet-public-b"
  }
}

resource "aws_subnet" "website-subnet-private-a" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  assign_ipv6_address_on_creation = false
  availability_zone               = "${element(var.aws_region_azs, 0)}"
  cidr_block                      = "${var.aws_vpc_subnet_cidrs["private-a"]}"
  map_public_ip_on_launch         = false

  tags = {
    Name = "website-subnet-private-a"
  }
}

resource "aws_subnet" "website-subnet-private-b" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  assign_ipv6_address_on_creation = false
  availability_zone               = "${element(var.aws_region_azs, 1)}"
  cidr_block                      = "${var.aws_vpc_subnet_cidrs["private-b"]}"
  map_public_ip_on_launch         = false

  tags = {
    Name = "website-subnet-private-b"
  }
}

resource "aws_eip" "website-eip-ngw-a" {
  count = 1
  vpc   = true

  tags = {
    Name = "website-eip-ngw-a"
  }
}

resource "aws_eip" "website-eip-ngw-b" {
  count = 1
  vpc   = true

  tags = {
    Name = "website-eip-ngw-b"
  }
}

resource "aws_nat_gateway" "website-ngw-a" {
  subnet_id     = "${aws_subnet.website-subnet-public-a.id}"
  allocation_id = "${aws_eip.website-eip-ngw-a.id}"

  tags = {
    Name = "website-ngw-a"
  }
}

resource "aws_nat_gateway" "website-ngw-b" {
  subnet_id     = "${aws_subnet.website-subnet-public-b.id}"
  allocation_id = "${aws_eip.website-eip-ngw-b.id}"

  tags = {
    Name = "website-ngw-b"
  }
}

resource "aws_route_table" "website-route-public" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.website-igw.id}"
  }

  tags = {
    Name = "website-route-public"
  }
}

resource "aws_route_table" "website-route-private-a" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.website-ngw-a.id}"
  }

  tags = {
    Name = "website-route-private"
  }
}

resource "aws_route_table" "website-route-private-b" {
  vpc_id = "${aws_vpc.website-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.website-ngw-b.id}"
  }

  tags = {
    Name = "website-route-private"
  }
}

resource "aws_route_table_association" "website-subnet-private-a" {
  subnet_id      = "${aws_subnet.website-subnet-private-a.id}"
  route_table_id = "${aws_route_table.website-route-private-a.id}"
}

resource "aws_route_table_association" "website-subnet-private-b" {
  subnet_id      = "${aws_subnet.website-subnet-private-b.id}"
  route_table_id = "${aws_route_table.website-route-private-b.id}"
}

resource "aws_route_table_association" "website-subnet-public-a" {
  subnet_id      = "${aws_subnet.website-subnet-public-a.id}"
  route_table_id = "${aws_route_table.website-route-public.id}"
}

resource "aws_route_table_association" "website-subnet-public-b" {
  subnet_id      = "${aws_subnet.website-subnet-public-b.id}"
  route_table_id = "${aws_route_table.website-route-public.id}"
}

resource "aws_security_group" "website-sg-alb" {
  name        = "website-sg-alb"
  description = "Allow all HTTP/S from Internet to ALB"
  vpc_id      = "${aws_vpc.website-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "website-sg-alb"
  }
}

resource "aws_security_group" "website-sg-appserver" {
  name        = "website-sg-appserver"
  description = "Allow HTTP from ALB"
  vpc_id      = "${aws_vpc.website-vpc.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.website-sg-alb.id}"]
  }

  tags = {
    Name = "website-sg-appserver"
  }
}

resource "aws_security_group" "website-sg-db" {
  name        = "website-sg-db"
  description = "Allow MySQL 3306 from Application Server"
  vpc_id      = "${aws_vpc.website-vpc.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.website-sg-appserver.id}"]
  }

  tags = {
    Name = "website-sg-db"
  }
}
