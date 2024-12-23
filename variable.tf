variable "vpc_tags" {
    type = map
    default = {}
}

variable "environment" {
    type = string
}

variable "project" {
    type = string
}

variable "cidr_block" {
    type = string
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
}

variable "common_tags" {
    type = map
    default = {
        Terraform= "True"
    }
}

variable "igw_tags" {
    type = map
    default = {}
}

variable "public_subnet_tags" {
    type = map
    default = {}
}

variable "public_subnets" {
    type = list(string)
    validation {
      condition = length(var.public_subnets) == 2
      error_message = "Please provide only 2 cidrs for public subnet"
    }
}

variable "private_subnet_tags" {
    type = map
    default = {}
}

variable "private_subnets" {
    type = list(string)
    validation {
      condition = length(var.private_subnets) == 2
      error_message = "Please provide only 2 cidrs for private subnet"
    }
}

variable "database_subnet_tags" {
    type = map
    default = {}
}

variable "database_subnets" {
    type = list(string)
    validation {
      condition = length(var.database_subnets) == 2
      error_message = "Please provide only 2 cidrs for database subnet"
    }
}