# output "az_info" {
#   value = data.aws_availability_zones.available
# }

output "vpc_id" {
    value = aws_vpc.main.id
}

output "default_vpc" {
    value = data.aws_vpc.selected
}

output "default_vpc_route_table" {
    value = data.aws_route_table.main
}

output "public_subnets_id" {
  value = aws_subnet.public[*].id
}

output "private_subnets_id" {
  value = aws_subnet.private[*].id
}

output "database_subnets_id" {
    value = aws_subnet.database[*].id 
}

output "database_subnet_group_name" {
    value = aws_db_subnet_group.default.name
  
}


