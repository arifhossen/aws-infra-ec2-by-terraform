# VPC Configuration
resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.organization}_${var.project_name}_${var.stage}"
  }
}
# Public Subnets-1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.organization}_${var.project_name}_public_subnet1_${var.stage}"

  }
}

# Public Subnets-2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.organization}_${var.project_name}_public_subnet2_${var.stage}"
  }
}

# Private Subnets-1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zone_1
  tags = {
    Name = "${var.organization}_${var.project_name}_private_subnet1_${var.stage}"
  }
}
# Private Subnets-2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zone_2
  tags = {
    Name = "${var.organization}_${var.project_name}_private_subnet2_${var.stage}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.organization}_${var.project_name}_igw_${var.stage}"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = var.public_route_tbl_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.organization}_${var.project_name}_public_rt_${var.stage}"
  }
}

# Route table Association with public-subnet-1
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
#Route table Association with public-subnet-2
resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}


# DB Subnet Group
resource "aws_db_subnet_group" "mysql_subnet" {
  name       = "${var.organization}_${var.project_name}_mysql_subnet_group_${var.stage}"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "${var.organization}_${var.project_name}_mysql_subnet_group_${var.stage}"
  }
}



# VPC Flow Logs Configuration
# This section sets up VPC Flow Logs to monitor and log network traffic in the VPC
# It includes creating a CloudWatch Log Group, an IAM Role for the flow logs, and
# enabling flow logs for the VPC.


# 1. Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.organization}_${var.project_name}_${var.stage}"
  retention_in_days = 14
}

# 2. IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.organization}_${var.project_name}_vpcFlowLogsRoles_${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# 3. IAM Policy for the role to write to CloudWatch
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.organization}_${var.project_name}_vpcFlowLogsPolicy_${var.stage}"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# 4. Enable Flow Logs for a VPC
resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL" # or "ACCEPT", "REJECT"
  vpc_id               = aws_vpc.main_vpc.id
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
}

