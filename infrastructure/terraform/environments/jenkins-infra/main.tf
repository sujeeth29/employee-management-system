data "terraform_remote_state" "dev_infra" {
  backend = "s3"
  config = {
    bucket = "sujeeth-cloud-storage-2"
    key = "dev/state_file/dev.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_subnet" "emp_infra_jenkins_subnet" {
    vpc_id = data.terraform_remote_state.dev_infra.outputs.dev_infra_vpc_id
    cidr_block = "10.0.2.180/30"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.env}-pub-1-subnet-1a"
    }
}

resource "aws_security_group" "emp_infra_jenkins_security_group" {
  vpc_id = data.terraform_remote_state.dev_infra.outputs.dev_infra_vpc_id
  name = "${var.env}-security-group"
  description = "Security group for jenkins server"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 8080
    to_port = 8080
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


module "emp_infra_ec2_jenkins" {
  source = "../../modules/ec2"
  env = var.env
  emp_infra_vpc_id = data.terraform_remote_state.dev_infra.outputs.dev_infra_vpc_id
  pub_subnet_id = aws_subnet.emp_infra_jenkins_subnet.id
  instance_name = var.instance_name
  pub_instance_type = var.pub_instance_type
  pub_security_group = aws_security_group.emp_infra_jenkins_security_group.id
}

