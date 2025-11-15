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

variable "log_retention_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 7
}
