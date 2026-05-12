############################################################
# ECR REPOSITORY
############################################################

resource "aws_ecr_repository" "app" {
  name = "git-onlinemobilestore-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name = "git-onlinemobilestore-ecr"
  }
}
