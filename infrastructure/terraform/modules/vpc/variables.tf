variable "emp_infra_env" {
  type = string
}

variable "emp_infra_public_subnets_keys" {
  type = map(object({
    cidr = string
    availability_zone = string
    map_public_ip_on_launch = bool
    subnet_name = string 
  }))
}

variable "emp_infra_private_subnet_keys" {
  type = map(object({
    cidr = string
    availability_zone = string
    subnet_name = string
  }))
}