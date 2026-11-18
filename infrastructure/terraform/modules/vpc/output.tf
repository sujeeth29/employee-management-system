output "emp_infra_vpc_id" {
    value = aws_vpc.emp_infra_vpc.id
}

output "emp_infra_pub_1_app_subnet_id" {
  value = aws_subnet.emp_infra_pub_1_app.id
}


