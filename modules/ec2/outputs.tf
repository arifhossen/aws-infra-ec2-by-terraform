output "instance_id" {
  value = aws_instance.main_ec2.id
}

output "instance_name" {
  value = aws_instance.main_ec2.tags.Name
}

output "ec2_name" {
  description = "EC2 instance name tag"
  value       = aws_instance.main_ec2.tags.Name
}

