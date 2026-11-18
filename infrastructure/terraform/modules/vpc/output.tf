output "emp_infra_vpc_id" {
    value = aws_vpc.emp_infra_vpc.id
}

output "emp_infra_public_subnet_ids" {
  value = {
    for key, subnet in aws_subnet.emp_infra_pub_1_app : 
    key => subnet.id
  }
}


