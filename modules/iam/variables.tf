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

variable "github_connection_arn" {
  description = "Notification email"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "artificate bucket arn"
  type        = string

}


