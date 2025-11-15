variable "stage" {}
variable "vpc_id" {}
variable "organization_name" {}
variable "project_name" {}
variable "subnet_ids" {
  description = "A list of subnet IDs"
  type        = list(string)
}
variable "security_group_id" {
  description = "Security Group id"
  type        = string
}

variable "security_group_name" {
  description = "Security Group Name"
  type        = string
}
variable "alb_security_group_id" {
  description = "Security Group id"
  type        = string
}

variable "alb_security_group_name" {
  description = "Security Group Name"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "key_name" {
  description = "The key name to use for the instances"
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


variable "ec2_iam_profile_name" {
  description = "Profile name "
  type        = string
}



