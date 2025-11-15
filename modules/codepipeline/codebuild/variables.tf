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

variable "codebuild_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  # Options: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE
}

variable "codebuild_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "codebuild_timeout" {
  description = "CodeBuild timeout in minutes"
  type        = number
  default     = 60
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2"
  type        = bool
  default     = true
}


variable "codebuild_role_arn" {
  type    = string
  default = "Codebuild iam role arn"

}

variable "ecr_repository_app_name" {
  type    = string
  default = "ECR Repository app name"

}


variable "aws_cloudwatch_log_group_codebuild_logs_name" {
  type    = string
  default = "Cloudwatch log group name for codebuild"

}

