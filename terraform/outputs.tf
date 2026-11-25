output "ecr_repository_url" {
  value = aws_ecr_repository.flask_app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.flask_app.name
}