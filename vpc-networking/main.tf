locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}"
  }
}

### VPC
resource "aws_vpc" "this" {
  cidr_block                       = "${var.vpc_cidr}"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = "false"
  tags                             = "${local.common_tags}"
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = "${local.common_tags}"
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${local.common_tags}"
}

### NAT
resource "aws_eip" "nats" {
  count      = "${var.nat_per_az ? length(var.azs) : 1}"
  vpc        = "true"
  depends_on = ["aws_internet_gateway.this"]

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("nat-${local.common_tags["Environment"]}-%d", count.index)
    )
  )}"
}

resource "aws_nat_gateway" "this" {
  count         = "${var.nat_per_az ? length(var.azs) : 1}"
  allocation_id = "${element(aws_eip.nats.*.id, count.index)}"

  subnet_id = "${var.nat_per_az ? 
    element(aws_subnet.public.*.id, count.index) : 
    aws_subnet.public.0.id
  }"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-%d", count.index)
    )
  )}"
}

### PUBLIC SUBNETS
resource "aws_subnet" "public" {
  count                           = "${length(var.public_subnets)}"
  vpc_id                          = "${aws_vpc.this.id}"
  map_public_ip_on_launch         = "false"
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "${element(var.public_subnets, count.index)}"
  availability_zone               = "${element(var.azs, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-public-%d", count.index)
    )
  )}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.common_tags["Environment"]}-public"
    )
  )}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

### PRIVATE SUBNETS
resource "aws_subnet" "private" {
  count                           = "${length(var.private_subnets)}"
  vpc_id                          = "${aws_vpc.this.id}"
  map_public_ip_on_launch         = "false"
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "${element(var.private_subnets, count.index)}"
  availability_zone               = "${element(var.azs, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-private-%d", count.index)
    )
  )}"
}

resource "aws_route_table" "private" {
  count  = "${var.nat_per_az ? length(var.private_subnets) : 1}"
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-private-%d", count.index)
    )
  )}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  route_table_id = "${var.nat_per_az ?
    element(aws_route_table.private.*.id, count.index) :
    aws_route_table.private.0.id
  }"

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route" "private" {
  count                  = "${var.nat_per_az ? length(var.private_subnets) : 1}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}
