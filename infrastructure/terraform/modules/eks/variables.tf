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