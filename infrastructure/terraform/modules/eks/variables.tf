variable "emp_infra_pri_subnets" {
  type = list(string)
}

variable "emp_infra_env" {
  type = string
}

variable "emp_infra_cluster_authentication_mode" {
  type = string
}

variable "emp_infra_cluster_version" {
  type = string
}

variable "emp_infra_node_group_policies" {
  type = list(string)
}

variable "emp_infra_node_group_instance_type" {
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

variable "emp_infra_cluster_bastion_instance_type" {
  type = string
}

variable "emp_infra_enable_cluster_bastion_server" {
  type = bool
}