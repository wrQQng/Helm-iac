resource "aws_ecr_repository" "app" {
  name                 = "${local.env}-todo-app-backend"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${local.env}-app"
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "${local.env}-todo-app-frontend"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${local.env}-app"
  }
}