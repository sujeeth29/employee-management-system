variable "emp_infra_pri_subnets" {
  type = list(string)
}

variable "env" {
  type = string
}

variable "authentication_mode" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "node_group_policies" {
  type = list(string)
}

variable "node_group_instance_type" {
  type = string
}

# variable "cluster_bastion_security_group_id" {
#   type = string
# }
variable "emp_infra_vpc_id" {
  type = string
}

variable "emp_infra_cluster_bastion_subnet" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}

variable "enable_cluster_bastion_server" {
  type = bool
}