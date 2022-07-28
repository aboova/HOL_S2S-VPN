################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count = local.create_vpc && length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = format(
      "%s-%s",
      var.tags,
      var.public_route_table_tags,
    )
  }
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_vpc && var.create_igw && length(local.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  count = local.create_vpc && length(local.private_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = format(
      "%s-%s",
      var.tags,
      var.private_route_table_tags
    )
  }
}

resource "aws_route" "private_nat_gateway" {

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.this.id

}

################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "public" {
  count = local.create_vpc && length(local.public_subnets) > 0 ? length(local.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = local.create_vpc && length(local.private_subnets) > 0 ? length(local.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}