dev_infra_env = "dev"
dev_infra_instance_name = "bastion"
dev_infra_pub_instance_type = "t3.micro"
dev_infra_repo_name = [ "frontend", "backend" ]
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
  },
  "subnet_2" = {
    cidr = "10.0.4.0/24"
    availability_zone = "ap-south-1b"
    subnet_name = "subnet_1b"
  }

}

dev_infra_cluster_authentication_mode = "API"
dev_infra_cluster_version = "1.35"
dev_infra_cluster_node_group_policies = [  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" ]
dev_infra_node_group_instance_type = "t3.medium"
dev_infra_cluster_bastion_instance_type = "t3.micro"
dev_infra_enable_cluster_bastion_server = true