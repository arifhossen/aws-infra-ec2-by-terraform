output "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "ec2_instance_profile_id" {
  description = "The ID of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.id
}

output "codebuild_iam_role_arn" {
  description = "CodeBuild IAM role arn"
  value       = aws_iam_role.codebuild_role.arn
}

output "codepipeline_role_iam_role_arn" {
  description = "CodePipeline IAM role arn"
  value       = aws_iam_role.codepipeline_role.arn
}
output "codedeploy_iam_role_arn" {
  description = "CodeDeploy IAM role arn"
  value       = aws_iam_role.codedeploy_role.arn
}


