# ============================================================================
# CodeBuild Information
# ============================================================================

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.app_build.name
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.app_build.arn
}

output "codebuild_logs_url" {
  description = "URL to view CodeBuild logs"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${replace(var.aws_cloudwatch_log_group_codebuild_logs_name, "/", "$252F")}"
}
