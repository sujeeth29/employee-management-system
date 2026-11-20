variable "dev_infra_env" {
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

variable "dev_infra_instance_name" {
  type = string
}

variable "dev_infra_pub_instance_type" {
  type = string
}

variable "dev_infra_private_subnets" {
  type = map(object({
    cidr = string
    availability_zone = string
    subnet_name = string
  }))
}

variable "dev_infra_repo_name" {
  type = list(string)
}

variable "dev_infra_cluster_authentication_mode" {
  type = string
}

variable "dev_infra_cluster_version" {
  type = string
}

variable "dev_infra_cluster_node_group_policies" {
  type = list(string)
}

variable "dev_infra_node_group_instance_type" {
  type = string
}

variable "dev_infra_cluster_bastion_instance_type" {
  type = string
}

variable "dev_infra_enable_cluster_bastion_server" {
  type = bool
}