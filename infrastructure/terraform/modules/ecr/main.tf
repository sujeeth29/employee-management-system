resource "aws_ecr_repository" "emp_infra_image_registry" {
  name = "${var.env}-infra-repo-${var.repo_name}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}