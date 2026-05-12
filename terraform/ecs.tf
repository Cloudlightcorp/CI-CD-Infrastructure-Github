############################################################
# NETWORK (DEFAULT VPC + SUBNETS)
############################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################################################
# CLOUDWATCH LOG GROUP
############################################################

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/git-onlinemobilestore"
}

############################################################
# ECS CLUSTER
############################################################

resource "aws_ecs_cluster" "main" {
  name = "git-onlinemobilestore-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

############################################################
# ECS TASK DEFINITION
############################################################

resource "aws_ecs_task_definition" "app" {
  family                   = "git-onlinemobilestore-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/git-onlinemobilestore"
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

############################################################
# DEV SERVICE
############################################################

resource "aws_ecs_service" "dev" {
  name            = "git-onlinemobilestore-dev-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.app]
}

############################################################
# TEST SERVICE
############################################################

resource "aws_ecs_service" "test" {
  name            = "git-onlinemobilestore-test-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.app]
}

############################################################
# PROD SERVICE
############################################################

resource "aws_ecs_service" "prod" {
  name            = "git-onlinemobilestore-prod-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.app]
}
