resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge (
    var.vpc_tags,
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.igw_tags,
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block = var.public_subnets[count.index]

  tags = merge (
    var.public_subnet_tags,
    var.common_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
    count = length(var.private_subnets)
    vpc_id     = aws_vpc.main.id
    availability_zone = local.az_names[count.index]
    cidr_block = var.private_subnets[count.index]

    tags = merge (
        var.private_subnet_tags,
        var.common_tags,
        {
            Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        }
    )
}

resource "aws_subnet" "database" {
    count = length(var.database_subnets)
    vpc_id     = aws_vpc.main.id
    availability_zone = local.az_names[count.index]
    cidr_block = var.database_subnets[count.index]

    tags = merge (
        var.database_subnet_tags,
        var.common_tags,
        {
            Name = "${local.resource_name}-database-${local.az_names[count.index]}"
        }
    )
}


resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
        var.common_tags,
        {
            Name = local.resource_name
        }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

##Route tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-database"
    }
  )
}

##Routes

resource "aws_route" "public_igw" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private_nat" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database_nat" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

#Subnet association

resource "aws_route_table_association" "public" {
    count = length(var.public_subnets)
#   subnet_id      = aws_subnet.public[*].id
#   ERROR [aws_subnet.public is tuple with 2 elements ,Inappropriate value for attribute "subnet_id": string required.]
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnets)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count = length(var.database_subnets)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}