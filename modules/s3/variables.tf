variable "stage" {}
variable "organization" {}
variable "project_name" {}
variable "log_retention_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 7
}
