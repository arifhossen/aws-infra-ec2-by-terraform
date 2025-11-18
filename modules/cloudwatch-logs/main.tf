
# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ec2/${var.project_name}_${var.stage}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}_${var.stage}-app-logs"
  }
}

resource "aws_cloudwatch_log_group" "codebuild_logs" {
  name              = "/aws/codebuild/${var.project_name}_${var.stage}-build"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}_${var.stage}-codebuild-logs"
  }
}
