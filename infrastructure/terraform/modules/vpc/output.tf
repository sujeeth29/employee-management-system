output "emp_infra_vpc_id" {
    value = aws_vpc.emp_infra_vpc.id
}

output "emp_infra_public_subnet_ids" {
  value = values(aws_subnet.emp_infra_pub_subnets)[*].id
}

output "emp_infra_private_subnet_ids" {
  value = values(aws_subnet.emp_infra_pri_subnets)[*].id
}

