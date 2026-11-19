resource "aws_iam_role" "emp_infra_eks_cluster_role" {
  name = "${var.env}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "sts.AssumeRole",
                "sts.TagSession"
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
  name = "${var.env}-infra-cluster"
  access_config {
    authentication_mode = var.authentication_mode
  }
  version = var.cluster_version
  role_arn = aws_iam_role.emp_infra_eks_cluster_role.arn
  vpc_config {
    subnet_ids = var.emp_infra_pri_subnets
  }
  depends_on = [ aws_iam_role.emp_infra_eks_cluster_role ]
}

resource "aws_iam_role_policy_attachment" "emp_infra_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:Policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.emp_infra_eks_cluster_role.name
}

resource "aws_iam_role" "emp_infra_node_group_role" {
  name = "${var.env}-infra-cluster-nodegroup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "sts.AssumeRole"
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
  for_each = toset(var.node_group_policies)
  policy_arn = each.value
  role = aws_iam_role.emp_infra_node_group_role.name
}

resource "aws_eks_node_group" "emp_infra_cluster_node_group" {
  cluster_name = aws_eks_cluster.emp_infra_eks_cluster.name
  node_group_name = "${var.env}-cluster-node-group"
  node_role_arn = aws_iam_role.emp_infra_node_group_role.arn
  subnet_ids = var.emp_infra_pri_subnets
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