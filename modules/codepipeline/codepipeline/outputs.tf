# outputs.tf
# Output values for the CI/CD pipeline

# ============================================================================
# Pipeline Information
# ============================================================================

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.app.name
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.app.arn
}

output "codepipeline_url" {
  description = "URL to view the pipeline in AWS Console"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.app.name}/view"
}