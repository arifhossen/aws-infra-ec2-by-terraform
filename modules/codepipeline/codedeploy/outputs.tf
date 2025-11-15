# ============================================================================
# CodeDeploy Information
# ============================================================================
# Data source to get current AWS region
data "aws_region" "current" {}

# Data source to get current account ID
data "aws_caller_identity" "current" {}



output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.app.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.app.deployment_group_name
}

output "codedeploy_url" {
  description = "URL to view CodeDeploy in AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codedeploy/applications/${aws_codedeploy_app.app.name}"
}
