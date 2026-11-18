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

resource "aws_subnet" "emp_infra_pri_subnet_1a" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "${var.env}-pri-subent-1a"
  }
}

resource "aws_subnet" "emp_infra_pri_subnet_1b" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.env}-pri-subnet-1b"
  }
}

resource "aws_nat_gateway" "emp_infra_natgw" {
  vpc_id = aws_vpc.emp_infra_vpc.id
  availability_mode = "regional"
  tags = {
    Name = "${var.env}-natgw"
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
    Name = "${var.env}-pri-rt"
  }
}

resource "aws_route_table_association" "emp_infra_pri_rt_subnet_associa" {
  for_each = {subnet_1= aws_subnet.emp_infra_pri_subnet_1a.id, subnet_2=aws_subnet.emp_infra_pri_subnet_1b.id}
  route_table_id = aws_route_table.emp_infra_pri_rt.id
  subnet_id = each.value
}

