############################################################
# CODEPIPELINE USING SHARED S3 BUCKET
# (Same bucket used for Terraform state + pipeline artifacts)
############################################################

############################################################
# DEV PIPELINE
############################################################
resource "aws_codepipeline" "dev_pipeline" {
  name     = "CODECOMMIT-OnlineMobileStore-dev-ci_cd"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "terraform-codepipeline-shared-bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "ReactApp-ecs-cicd"
        BranchName     = "dev"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dev_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.dev.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

############################################################
# TEST PIPELINE
############################################################
resource "aws_codepipeline" "test_pipeline" {
  name     = "reactapp-test-ci_cd"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "terraform-codepipeline-shared-bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "ReactApp-ecs-cicd"
        BranchName     = "test"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.test.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

############################################################
# PROD PIPELINE
############################################################
resource "aws_codepipeline" "prod_pipeline" {
  name     = "reactapp-prod-ci_cd"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "terraform-codepipeline-shared-bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "ReactApp-ecs-cicd"
        BranchName     = "prod"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.prod.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
