locals {
  max_subnet_length = max(
    length(local.private_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_vpc = var.create_vpc
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = {
    Name = format(
      "%s-%s",
      var.environment,
      var.vpc_tags
    )
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = local.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  # Do not turn this into `local.vpc_id`
  vpc_id = aws_vpc.this[0].id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = local.create_vpc && var.create_igw && length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = format(
      "%s-%s",
      var.environment,
      var.igw_tags,
    )
  }
}


################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "for SSH accss"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "myself"
  }
  vpc_id = local.vpc_id
  tags = {
    Name = format(
      "%s-bastion-sg",
      var.environment
    )
  }
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = local.create_vpc && length(local.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(local.public_subnets) >= length(var.azs)) ? length(local.public_subnets) : 0

  vpc_id               = local.vpc_id
  cidr_block           = local.public_subnets[count.index].cidr
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
      "%s-%s-%s",
      var.environment,
      var.public_subnet_tags,
      local.private_subnets[count.index].zone_id
    )
  }
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = local.create_vpc && length(local.private_subnets) > 0 ? length(local.private_subnets) : 0

  vpc_id               = local.vpc_id
  cidr_block           = local.private_subnets[count.index].cidr
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = {
    Name = format(
      "%s-%s-%s",
      var.environment,
      var.private_subnet_tags,
      local.private_subnets[count.index].zone_id
    )
  }
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "eip_for_nat" {
  depends_on = [aws_route_table.public]
  tags = {
    Name = format(
      "%s-eip-nat",
      var.environment
    )
  }
}

resource "aws_nat_gateway" "this" {
  depends_on    = [aws_eip.eip_for_nat]
  allocation_id = aws_eip.eip_for_nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = format(
      "%s-nat",
      var.environment,
    )
  }
}