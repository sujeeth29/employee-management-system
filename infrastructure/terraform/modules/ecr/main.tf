resource "aws_ecr_repository" "emp_infra_image_registry" {
  name = "${var.emp_infra_env}-infra-repo-${var.emp_infra_repo_name}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}