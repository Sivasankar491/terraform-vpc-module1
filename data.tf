data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "selected" {
  default = true
}

data "aws_route_table" "main"{
  vpc_id = data.aws_vpc.selected.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}