resource "aws_ecr_repository" "backend" {
  name                 = "${local.env}-todo-app-backend"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  tags = {
    Name = "${local.env}-app"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${local.env}-todo-app-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  tags = {
    Name = "${local.env}-app"
  }
}