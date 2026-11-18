env = "dev"
instance_name = "bastion"
pub_instance_type = "t3.micro"
dev_repo_name = [ "frontend", "backend" ]
dev_infra_public_subnets = {
  "subnet_1" = {
    cidr = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    subnet_name = "subnet_1a"
  }
}

dev_infra_private_subnets = {
  "subnet_1" = {
    cidr = "10.0.3.0/24"
    availability_zone = "ap-south-1a"
    subnet_name = "subnet_1a"
  }
}