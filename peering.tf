resource "aws_vpc_peering_connection" "peering" {
#   peer_owner_id = var.peer_owner_id
  count = var.is_peering_required ? 1 : 0  
  peer_vpc_id   = data.aws_vpc.selected.id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-default"
    }
  )
}

resource "aws_route" "public_peering" {  
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.selected.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "default_peering" {  
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_vpc.selected.main_route_table_id
  destination_cidr_block    = var.public_subnets[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}