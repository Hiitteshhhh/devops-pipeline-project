terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ECR Repository — stores your Docker image
resource "aws_ecr_repository" "flask_app" {
  name                 = "flask-devops-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "flask-devops-api"
  }
}

# S3 Bucket — for Terraform state and app logs
resource "aws_s3_bucket" "devops_bucket" {
  bucket = "devops-flask-${var.account_id}"

  tags = {
    Name = "devops-flask-bucket"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.cluster_name
  }
}

# CloudWatch Log Group — for container logs
resource "aws_cloudwatch_log_group" "flask_app" {
  name              = "/ecs/flask-devops-api"
  retention_in_days = 7

  tags = {
    Name = "flask-devops-api-logs"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-devops"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition — describes your container
resource "aws_ecs_task_definition" "flask_app" {
  family                   = "flask-devops-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-devops-api"
      image     = "${aws_ecr_repository.flask_app.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/flask-devops-api"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "APP_ENV"
          value = "production"
        }
      ]
    }
  ])

  tags = {
    Name = "flask-devops-api"
  }
}