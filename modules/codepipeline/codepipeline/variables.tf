variable "stage" {
  description = "Stage dev,staging,prod"
  type        = string
}
variable "organization" {
  description = "Organization name"
  type        = string
}
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "notification_email" {
  description = "Notification email"
  type        = string

}


variable "github_repo_owner" {
  description = "GitHub repository owner/organization"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}


variable "github_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub (must be created manually first)"
  type        = string
  default     = ""
}

variable "create_github_connection" {
  description = "Create a new CodeStar GitHub connection (requires manual OAuth completion in console)"
  type        = bool
  default     = false
}


variable "aws_codebuild_project_name" {
  type    = string
  default = "Codebuild project name"

}

variable "aws_codedeploy_app_name" {
  type    = string
  default = "Codedeploy app name"

}

variable "aws_codedeploy_app_deployment_group_name" {
  type    = string
  default = "Codedeploy app deployment group name"

}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "ARN of the S3 bucket for pipeline artifacts"
  type        = string
}


variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2"
  type        = bool
  default     = true
}


variable "codepipeline_role_arn" {
  type    = string
  default = "Codepipeline iam role arn"

}
variable "ecr_repository_app_name" {
  type    = string
  default = "ECR Repository app name"

}


variable "enable_manual_approval" {
  description = "Add manual approval stage before deployment"
  type        = bool
  default     = false
}
