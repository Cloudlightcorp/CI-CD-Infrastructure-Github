############################################################
# CODESTAR CONNECTION (GITHUB)
############################################################

resource "aws_codestarconnections_connection" "github" {
  name          = "github-onlinemobilestore-connection"
  provider_type = "GitHub"
}

############################################################
# DEV PIPELINE
############################################################

resource "aws_codepipeline" "dev_pipeline" {
  name     = "GIT-OnlineMobileStore-dev-ci_cd"
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
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "Cloudlightcorp/GIT-OnlineMobileStore-build-ci_cd"
        BranchName           = "dev"
        DetectChanges        = "true"
        OutputArtifactFormat = "CODE_ZIP"
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
  name     = "GIT-OnlineMobileStore-test-ci_cd"
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
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "Cloudlightcorp/GIT-OnlineMobileStore-build-ci_cd"
        BranchName           = "test"
        DetectChanges        = "true"
        OutputArtifactFormat = "CODE_ZIP"
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
  name     = "GIT-OnlineMobileStore-prod-ci_cd"
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
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = "Cloudlightcorp/GIT-OnlineMobileStore-build-ci_cd"
        BranchName           = "prod"
        DetectChanges        = "true"
        OutputArtifactFormat = "CODE_ZIP"
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
