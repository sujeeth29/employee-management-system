resource "aws_vpc" "emp_infra_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "emp_infra_pub_1_app" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-app-pub-subnet-1a"
  }
}


resource "aws_internet_gateway" "emp_infra_igw" {
  tags = {
    Name = "${var.env}-igw"
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
    Name = "${var.env}-pub-rt"
  }
}

resource "aws_route_table_association" "emp_pub_rt_appsub_associa" {
  route_table_id = aws_route_table.emp_infra_pub_rt.id
  subnet_id = aws_subnet.emp_infra_pub_1_app.id
}


