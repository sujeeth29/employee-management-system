data "terraform_remote_state" "dev_infra" {
  backend = "s3"
  config = {
    bucket = "sujeeth-cloud-storage-2"
    key = "dev/state_file/dev.tfstate"
    region = "ap-south-1"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_subnet" "emp_infra_jenkins_subnet" {
    vpc_id = data.terraform_remote_state.dev_infra.outputs.dev_infra_vpc_id
    cidr_block = "10.0.2.180/30"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.jenkins_infra_env}-pub-1-subnet-1a"
    }
}

resource "aws_security_group" "emp_infra_jenkins_security_group" {
  vpc_id = data.terraform_remote_state.dev_infra.outputs.dev_infra_vpc_id
  name = "${var.jenkins_infra_env}-security-group"
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
  emp_infra_env = var.jenkins_infra_env
  emp_infra_vpc_id = data.terraform_remote_state.dev_infra.outputs.dev_infra_vpc_id
  emp_infra_pub_subnet_id = aws_subnet.emp_infra_jenkins_subnet.id
  emp_infra_instance_name = var.jenkins_infra_instance_name
  emp_infra_pub_instance_type = var.jenkins_infra_pub_instance_type
  emp_infra_pub_security_group = aws_security_group.emp_infra_jenkins_security_group.id
  emp_infra_public_instance_profile = aws_iam_instance_profile.jenkins_infra_server_ec2_policy.name
}

resource "aws_iam_role" "jenkins_infra_ec2_instance_role" {
  name = "jenkins_server_ec2_role"
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

resource "aws_iam_role" "jenkins_infra_cloud_access_role" {
  name = "jenkins_server_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Principal = { AWS = aws_iam_role.jenkins_infra_ec2_instance_role.arn }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_infra_server_ec2_policy" {
  role = aws_iam_policy.jenkins_infra_cloud_access_policy.name
  name = "jenkins-ec2-policy"
}

resource "aws_iam_policy" "jenkins_infra_cloud_access_policy" {
  name = "aws_cloud_access_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "Ec2 Access policy"
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Sid = "S3 Bucket access"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = "arn:aws:s3:::sujeeth-cloud-storage-2"
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "dev/state_file",
              "dev/state_file/*"
            ]
          }
        }
      },
      {
        Sid = "S3 bucket object access policy"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = ["arn:aws:s3:::sujeeth-cloud-storage-2/dev/state_file/*"]
      },
      {
        Sid = "S3 bucket state lock file access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::sujeeth-clud-storage-2/dev/state_file/*.tflock"
      },
      {
        Sid = "EKS Cluster resources"
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },
      {
        Sid = "Ecr access policy"
        Effect = "Allow"
        Action = ["ecr:*"]
        Resource = "*"
      },
      {
        Sid = "IAM access policy"
        Effect = "Allow"
        Action = ["iam:*"]
        Resource = "*"
      }
    ]
  })
}