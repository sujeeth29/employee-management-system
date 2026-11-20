module "dev_vpc" {
  source = "../../modules/vpc"
  emp_infra_env = var.dev_infra_env
  emp_infra_private_subnet_keys = var.dev_infra_private_subnets
  emp_infra_public_subnets_keys = var.dev_infra_public_subnets
}

# resource "aws_security_group" "dev_infra_bastion_security_group" {
#   vpc_id = module.dev_vpc.emp_infra_vpc_id
#   name = "${var.env}-bastion-security-group"
#   description = "Security group for dev Bastion server"
#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }
#   depends_on = [ module.dev_vpc ]
# }

# module "dev_infra_bastion_ec2" {
#   source = "../../modules/ec2"
#   env = var.env
#   emp_infra_vpc_id = module.dev_vpc.emp_infra_vpc_id
#   pub_subnet_id = module.dev_vpc.emp_infra_public_subnet_ids[0]
#   pub_instance_type = var.pub_instance_type
#   instance_name = var.instance_name
#   pub_security_group = aws_security_group.dev_infra_bastion_security_group.id
#   depends_on = [ module.dev_vpc ]
# }

module "dev_infra_ecr" {
  source = "../../modules/ecr"
  emp_infra_env = var.dev_infra_env
  for_each = toset(var.dev_infra_repo_name)
  emp_infra_repo_name = each.value
}

module "dev_infra_eks_cluster" {
  source = "../../modules/eks"
  emp_infra_env = var.dev_infra_env #
  emp_infra_pri_subnets = module.dev_vpc.emp_infra_private_subnet_ids #
  emp_infra_node_group_policies = var.dev_infra_cluster_node_group_policies #
  emp_infra_cluster_authentication_mode = var.dev_infra_cluster_authentication_mode #
  emp_infra_cluster_version = var.dev_infra_cluster_version #
  emp_infra_node_group_instance_type = var.dev_infra_node_group_instance_type #
  emp_infra_vpc_id = module.dev_vpc.emp_infra_vpc_id #
  emp_infra_cluster_bastion_subnet = module.dev_vpc.emp_infra_public_subnet_ids[0] #
  emp_infra_cluster_bastion_instance_type = var.dev_infra_cluster_bastion_instance_type
  emp_infra_enable_cluster_bastion_server = var.dev_infra_enable_cluster_bastion_server
  depends_on = [ module.dev_vpc ]
}

