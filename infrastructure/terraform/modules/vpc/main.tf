resource "aws_vpc" "emp_infra_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.emp_infra_env}-vpc"
  }
}

resource "aws_subnet" "emp_infra_pub_subnets" {
  for_each = var.emp_infra_public_subnets_keys
  vpc_id = aws_vpc.emp_infra_vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = "${var.emp_infra_env}-pub-${each.value.subnet_name}"
  }
}


resource "aws_internet_gateway" "emp_infra_igw" {
  tags = {
    Name = "${var.emp_infra_env}-igw"
  }
}

resource "aws_internet_gateway_attachment" "emp_infra_igw_vpc" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  internet_gateway_id = aws_internet_gateway.emp_infra_igw.id
}

resource "aws_route_table" "emp_infra_pub_rt" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.emp_infra_igw.id
  }
  tags = {
    Name = "${var.emp_infra_env}-pub-rt"
  }
}

resource "aws_route_table_association" "emp_pub_rt_appsub_associa" {
  count = length(values(aws_subnet.emp_infra_pub_subnets)[*].id)
  route_table_id = aws_route_table.emp_infra_pub_rt.id
  subnet_id = values(aws_subnet.emp_infra_pub_subnets)[count.index].id
}

resource "aws_subnet" "emp_infra_pri_subnets" {
  for_each = var.emp_infra_private_subnet_keys
  vpc_id = aws_vpc.emp_infra_vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.availability_zone
  tags = {
    Name = "${var.emp_infra_env}-pri-${each.value.subnet_name}"
  }
}

resource "aws_nat_gateway" "emp_infra_natgw" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  availability_mode = "regional"
  tags = {
    Name = "${var.emp_infra_env}-natgw"
  }
  depends_on = [ aws_internet_gateway.emp_infra_igw ]
}

resource "aws_route_table" "emp_infra_pri_rt" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.emp_infra_natgw.id
  }
  tags = {
    Name = "${var.emp_infra_env}-pri-rt"
  }
}

resource "aws_route_table_association" "emp_infra_pri_rt_subnet_associa" {
  count = length(values(aws_subnet.emp_infra_pri_subnets)[*].id)
  route_table_id = aws_route_table.emp_infra_pri_rt.id
  subnet_id = values(aws_subnet.emp_infra_pri_subnets)[count.index].id
}

