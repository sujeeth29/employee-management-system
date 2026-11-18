output "ubuntu_image" {
  value = data.aws_ami.emp_infra_ubuntu_image.id
}