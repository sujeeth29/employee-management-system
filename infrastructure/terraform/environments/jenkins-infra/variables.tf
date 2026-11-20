variable "jenkins_infra_env" {
  type = string
}

variable "jenkins_infra_instance_name" {
  type = string
}

variable "jenkins_infra_pub_instance_type" {
  type = string
}

# variable "jenkins_infra_public_subnet_keys" {
#   type = map(object({
#     cidr = string
#     availability_zone = string
#     map_public_ip_on_launch = bool
#     subnet_name = string
#   }))
# }