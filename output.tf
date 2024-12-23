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