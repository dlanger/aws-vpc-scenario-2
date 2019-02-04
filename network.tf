locals {
  common_tags = {
    Cost-centre = "infrastructure"
    Service     = "common"
    Environment = "${var.environment}"
    Name        = "${var.environment}"
  }

  public_subnet_offset  = 1
  private_subnet_offset = 11
}

### VPC

resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = "${local.common_tags}"
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${local.common_tags}"
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${local.common_tags}"
}

### NAT

resource "aws_eip" "nats" {
  count = "${length(var.azs)}"

  vpc        = "true"
  depends_on = ["aws_internet_gateway.main"]

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("nat-${local.common_tags["Environment"]}-%d", count.index)
    )
  )}"
}

resource "aws_nat_gateway" "main" {
  count = "${length(var.azs)}"

  allocation_id = "${element(aws_eip.nats.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-%d", count.index)
    )
  )}"
}

### PUBLIC SUBNETS

resource "aws_subnet" "public" {
  count = "${var.num_subnets}"

  vpc_id                          = "${aws_vpc.main.id}"
  map_public_ip_on_launch         = "false"
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "${cidrsubnet(var.vpc_cidr, 8, local.public_subnet_offset + count.index)}"
  availability_zone               = "${element(var.azs, count.index % length(var.azs))}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-public-%d", count.index)
    )
  )}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

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
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "public" {
  count = "${var.num_subnets}"

  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

### PRIVATE SUBNETS

resource "aws_subnet" "private" {
  count = "${var.num_subnets}"

  vpc_id                          = "${aws_vpc.main.id}"
  map_public_ip_on_launch         = "false"
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "${cidrsubnet(var.vpc_cidr, 8, local.private_subnet_offset + count.index)}"
  availability_zone               = "${element(var.azs, count.index % length(var.azs))}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-private-%d", count.index)
    )
  )}"
}

resource "aws_route_table" "private" {
  count = "${length(var.azs)}"

  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", format("${local.common_tags["Environment"]}-private-%d", count.index)
    )
  )}"
}

resource "aws_route_table_association" "private" {
  count = "${var.num_subnets}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index % length(var.azs))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route" "private" {
  count = "${length(var.azs)}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${element(aws_nat_gateway.main.*.id, count.index)}"

  lifecycle {
    # AWS API often reports gateway_id changing to or from "" when no real  
    # change is needed or possible
    ignore_changes = ["gateway_id"]
  }
}
