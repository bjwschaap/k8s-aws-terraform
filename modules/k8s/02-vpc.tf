// This file defines all VPC specific settings like subnets, gateways and
// routing tables.

//  Define the VPC.
resource "aws_vpc" "k8s" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name    = "${var.vpc_name}"
    Project = "k8s"
  }
}

// Create the DHCP options
resource "aws_vpc_dhcp_options" "k8s" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.vpc_name}-dopt"
    Project = "k8s"
  }
}

// Associate the DHCP options with the VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.k8s.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.k8s.id}"
}

//  Create an Internet Gateway for the public subnets in the VPC.
resource "aws_internet_gateway" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  tags {
    Name    = "${var.vpc_name}-igw"
    Project = "k8s"
  }
}

//  Create the public subnets.
resource "aws_subnet" "public-subnets" {
  count                   = 3
  vpc_id                  = "${aws_vpc.k8s.id}"
  cidr_block              = "${element(var.public_subnet_cidr_list, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.k8s"]

  tags {
    Name              = "k8s-public_subnet-${count.index + 1}"
    Project           = "k8s"
    KubernetesCluster = "${var.stackname}"
  }
}

//  Create a route table allowing all subnets to access to the IGW.
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.k8s.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s.id}"
  }

  tags {
    Name    = "${var.vpc_name}-public-rt"
    Project = "k8s"
  }
}

//  Now associate the route table with the public subnets - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "public-subnets" {
  count          = 3
  subnet_id      = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
  depends_on     = ["aws_subnet.public-subnets"]
}

// Create an Elastic IP and let the NAT gateway use it
// to allow the private subnets to go to the internet
resource "aws_eip" "k8s_nat" {
  vpc    = true
  
  tags {
    Name    = "${var.vpc_name}-nat-eip"
    Project = "k8s"
  }
}

// Create a NAT gateway for the private subnets in the VPC. Just use the
// first public subnet to bind to.
resource "aws_nat_gateway" "k8s" {
  subnet_id     = "${aws_subnet.public-subnets.0.id}"
  allocation_id = "${aws_eip.k8s_nat.id}"

  tags {
    Name    = "${var.vpc_name}-ngw"
    Project = "k8s"
  }
}

//  Create the private subnets.
resource "aws_subnet" "private-subnets" {
  count                   = 3
  vpc_id                  = "${aws_vpc.k8s.id}"
  cidr_block              = "${element(var.private_subnet_cidr_list, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  depends_on              = ["aws_nat_gateway.k8s"]

  tags {
    Name              = "k8s-private_subnet-${count.index + 1}"
    Project           = "k8s"
    KubernetesCluster = "${var.stackname}"
  }
}

// The private routing table, directing traffic through the NAT gateway
resource "aws_route_table" "private" {
  vpc_id     = "${aws_vpc.k8s.id}"
  depends_on = ["aws_nat_gateway.k8s"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.k8s.id}"
  }

  tags {
    Name    = "${var.vpc_name}-private-rt"
    Project = "k8s"
  }
}

//  Now associate the private route table with the private subnets - giving
//  all private subnet instances access to the NAT gateway.
resource "aws_route_table_association" "private-subnets" {
  count          = 3
  subnet_id      = "${element(aws_subnet.private-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
  depends_on     = ["aws_subnet.private-subnets"]
}
