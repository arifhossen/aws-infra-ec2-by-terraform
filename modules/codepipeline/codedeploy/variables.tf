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

variable "ec2_instance_name" {
  description = "Instance name tag for EC2 instances"
  type        = string

}

variable "codedeploy_role_arn" {
  type    = string
  default = "CodeDeploy iam role arn"

}
variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration"
  type        = string
}


variable "enable_auto_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}
variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring for EC2"
  type        = bool
  default     = true
}
