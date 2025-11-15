output "ec2_sg_id" {
  description = "The ID of the security group."
  value       = aws_security_group.ec2_sg.id
}

output "ec2_sg_name" {
  description = "The Name of the security group name"
  value       = aws_security_group.ec2_sg.name
}

output "alb_sg_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.alb_sg.id
}

output "alb_sg_name" {
  description = "The ALB security group name."
  value       = aws_security_group.alb_sg.name
}
