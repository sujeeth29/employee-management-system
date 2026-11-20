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
    subnet_id = var.emp_infra_pub_subnet_id
    iam_instance_profile = var.emp_infra_public_instance_profile
    security_groups = [ var.emp_infra_pub_security_group ]
    instance_type = var.emp_infra_pub_instance_type
    tags = {
      Name = "${var.emp_infra_env}-server-${var.emp_infra_instance_name}"
    }
}