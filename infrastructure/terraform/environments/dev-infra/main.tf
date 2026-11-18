module "dev_vpc" {
  source = "../../modules/vpc"
  env = var.env
}

resource "aws_security_group" "dev_infra_bastion_security_group" {
  vpc_id = module.dev_vpc.emp_infra_vpc_id
  name = "${var.env}-bastion-security-group"
  description = "Security group for dev Bastion server"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

module "dev_infra_bastion_ec2" {
  source = "../../modules/ec2"
  env = var.env
  emp_infra_vpc_id = module.dev_vpc.emp_infra_vpc_id
  pub_subnet_id = module.dev_vpc.emp_infra_pub_1_app_subnet_id
  pub_instance_type = var.instance_name
  instance_name = var.pub_instance_type
  pub_security_group = aws_security_group.dev_infra_bastion_security_group.id
}

module "dev_infra_ecr" {
  source = "../../modules/ecr"
  env = var.env
  for_each = toset(var.dev_repo_name)
  repo_name = each.value
}