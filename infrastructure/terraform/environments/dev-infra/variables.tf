variable "env" {
  type = string
}

variable "dev_infra_public_subnets" {
  type = map(object({
    cidr = string
    availability_zone = string
    map_public_ip_on_launch = bool
    subnet_name = string
  }))
}

variable "instance_name" {
  type = string
}

variable "pub_instance_type" {
  type = string
}

variable "dev_infra_private_subnets" {
  type = map(object({
    cidr = string
    availability_zone = string
    subnet_name = string
  }))
}

variable "dev_repo_name" {
  type = list(string)
}


# variable "dev_cluster_node_group_policies" {
#   type = list(string)
# }
