data "aws_ami" "emp_infra_ubuntu_image" {
  owners = [ "099720109477" ]
  most_recent = true
  filter {
    name = "name"
    values = [ "ubuntu/images/hvm-ssd-gp3/ubuntu-*-*-amd64-server-*" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}


resource "aws_instance" "emp_infra_pub_server" {
    ami = data.aws_ami.emp_infra_ubuntu_image.id
    subnet_id = var.pub_subnet_id
    security_groups = [ var.pub_security_group ]
    instance_type = var.pub_instance_type
    tags = {
      Name = "${var.env}-server-${var.instance_name}"
    }
}