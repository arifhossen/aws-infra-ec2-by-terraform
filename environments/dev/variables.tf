variable "stage" {
  description = "Stage poc,dev,prod"
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

variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "ami_id" {
  description = "AWS Machine ami id"
  type        = string
}

variable "instance_type" {
  description = "AWS Machine Instance Type"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR Block"
  type        = string
}


variable "public_subnet_1_cidr" {
  description = "Public subnet 1 CIDR Block"
  type        = string
}


variable "public_subnet_2_cidr" {
  description = "Public subnet 2 CIDR Block"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "Private subnet 1 CIDR Block"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "Private subnet 2 CIDR Block"
  type        = string
}

variable "public_route_tbl_cidr_block" {
  description = "Public Route table CIDR Block"
  type        = string
}

variable "availability_zone_1" {
  description = "Availability Zone 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability Zone 2"
  type        = string
}

variable "acm_certificate_arn" {
  description = "AWS ACM Certificate Arn"
  type        = string
}

variable "route53_zone_id" {
  description = "AWS Route 53 Zone ID"
  type        = string
}

variable "domain_name" {
  description = "AWS Domain name"
  type        = string
}

variable "frontend_domain_name" {
  description = "Frontend subdomain  name"
  type        = string
}

variable "notification_email" {
  description = "Notification email"
  type        = string

}


variable "create_github_connection" {
  description = "Create GitHub connection (requires manual OAuth completion in console)"
  type        = bool
  default     = false
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

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push to ECR"
  type        = bool
  default     = true
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



variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration"
  type        = string
  default     = "CodeDeployDefault.OneAtATime"
  # Options: 
  # - CodeDeployDefault.OneAtATime
  # - CodeDeployDefault.HalfAtATime
  # - CodeDeployDefault.AllAtOnce
}

variable "enable_manual_approval" {
  description = "Add manual approval stage before deployment"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 7
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "codedeploy_agent_version" {
  description = "CodeDeploy agent version to install"
  type        = string
  default     = "latest"
}

variable "enable_ecr_lifecycle_policy" {
  description = "Enable ECR lifecycle policy to remove old images"
  type        = bool
  default     = true
}

variable "ecr_image_retention_count" {
  description = "Number of images to retain in ECR"
  type        = number
  default     = 10
}

variable "enable_auto_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

variable "auto_scaling_enabled" {
  description = "Enable auto-scaling for EC2 instances"
  type        = bool
  default     = false
}

