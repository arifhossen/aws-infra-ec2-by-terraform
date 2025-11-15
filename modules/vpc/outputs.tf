output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}
output "public_subnet_2" {
  value = aws_subnet.public_subnet_2.id
}

output "aws_db_subnet_group_name" {
  value = aws_db_subnet_group.mysql_subnet.name
}


