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