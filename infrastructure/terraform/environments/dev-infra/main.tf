module "dev_vpc" {
  source = "../../modules/vpc"
  env = var.env
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
  env = var.env
  for_each = toset(var.dev_repo_name)
  repo_name = each.value
}

module "dev_infra_eks_cluster" {
  source = "../../modules/eks"
  env = var.env
  emp_infra_pri_subnets = module.dev_vpc.emp_infra_private_subnet_ids
  node_group_policies = var.dev_cluster_node_group_policies
  authentication_mode = var.dev_infra_cluster_authentication_mode
  cluster_version = var.dev_infra_cluster_version
  node_group_instance_type = var.dev_infra_node_group_instance_type
  emp_infra_vpc_id = module.dev_vpc.emp_infra_vpc_id
  emp_infra_cluster_bastion_subnet = module.dev_vpc.emp_infra_public_subnet_ids[0]
  bastion_instance_type = var.cluster_bastion_instance_type
  enable_cluster_bastion_server = var.enable_cluster_bastion_server
  depends_on = [ module.dev_vpc ]
}