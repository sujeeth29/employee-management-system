############# EKS Cluster Config ####################
resource "aws_iam_role" "emp_infra_eks_cluster_role" {
  name = "${var.emp_infra_env}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_eks_cluster" "emp_infra_eks_cluster" {
  name = "${var.emp_infra_env}-infra-cluster"
  access_config {
    authentication_mode = var.emp_infra_cluster_authentication_mode
  }
  version = var.emp_infra_cluster_version
  role_arn = aws_iam_role.emp_infra_eks_cluster_role.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = false
    subnet_ids = var.emp_infra_pri_subnets
  }
  depends_on = [ aws_iam_role.emp_infra_eks_cluster_role ]
}

resource "aws_security_group_rule" "emp_infra_cluster_security_group_ingress" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_eks_cluster.emp_infra_eks_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.emp_infra_cluster_bastion_security_group[count.index].id
}


resource "aws_iam_role_policy_attachment" "emp_infra_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.emp_infra_eks_cluster_role.name
}
############################################################

################# EKS Cluster Bastion ################

data "aws_ami" "emp_infra_amz_linux_ami_id" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-x86_64-gp2" ]
  }
  filter {
    name = "architecture"
    values = [ "X86_64" ]
  }
}

resource "aws_security_group" "emp_infra_cluster_bastion_security_group" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  vpc_id = var.emp_infra_vpc_id
  name = "${var.emp_infra_env}-cluster-bastion-security-group"
  description = "${var.emp_infra_env} cluster bastion's security group"
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

resource "aws_instance" "emp_infra_cluster_bastion" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  ami = data.aws_ami.emp_infra_amz_linux_ami_id.id
  subnet_id = var.emp_infra_cluster_bastion_subnet
  security_groups = [ aws_security_group.emp_infra_cluster_bastion_security_group[count.index].id ]
  iam_instance_profile = aws_iam_instance_profile.emp_infra_cluster_bastion_instance_policy[count.index].name
  instance_type = var.emp_infra_cluster_bastion_instance_type
  tags = {
    Name = "${var.emp_infra_env}-cluster-bastion"
  }
}

resource "aws_iam_role" "emp_infra_cluster_bastion_role" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  name = "${var.emp_infra_env}-cluster-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "emp_infra_cluster_bastion_policy" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  name = "${var.emp_infra_env}-cluster-bastion-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluser",
          "eks:ListClusters"
        ]
        Resource = [ aws_eks_cluster.emp_infra_eks_cluster.arn ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emp_infra_bastion_role_policy_attach" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  role = aws_iam_role.emp_infra_cluster_bastion_role[count.index].arn
  policy_arn = aws_iam_policy.emp_infra_cluster_bastion_policy[count.index].arn
}

resource "aws_iam_instance_profile" "emp_infra_cluster_bastion_instance_policy" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  role = aws_iam_role.emp_infra_cluster_bastion_role[count.index].name
  name = "${var.emp_infra_env}-cluster-bastion-instance-policy"
}

resource "aws_eks_access_entry" "emp_infra_cluster_access_entry" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  cluster_name = aws_eks_cluster.emp_infra_eks_cluster.name
  principal_arn = aws_iam_role.emp_infra_cluster_bastion_role[count.index].arn
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "emp_infra_cluster_access_policy" {
  count = var.emp_infra_enable_cluster_bastion_server ? 1 : 0
  cluster_name = aws_eks_cluster.emp_infra_eks_cluster.name
  policy_arn = "arn:aws:eks::aws:cluster_access_policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.emp_infra_cluster_bastion_role[count.index].arn
  access_scope {
    type = "cluster"
  }
}

############### EKS cluster node group #################


resource "aws_iam_role" "emp_infra_node_group_role" {
  name = "${var.emp_infra_env}-infra-cluster-nodegroup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "sts:AssumeRole"
            ]
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emp_infra_node_group_policies_attachment" {
  for_each = toset(var.emp_infra_node_group_policies)
  policy_arn = each.value
  role = aws_iam_role.emp_infra_node_group_role.name
}

resource "aws_eks_node_group" "emp_infra_cluster_node_group" {
  cluster_name = aws_eks_cluster.emp_infra_eks_cluster.name
  node_group_name = "${var.emp_infra_env}-cluster-node-group"
  node_role_arn = aws_iam_role.emp_infra_node_group_role.arn
  subnet_ids = var.emp_infra_pri_subnets
  instance_types = [ var.emp_infra_node_group_instance_type ]
  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }
  update_config {
    max_unavailable = 1
  }

  depends_on = [ aws_iam_role.emp_infra_node_group_role ]
}