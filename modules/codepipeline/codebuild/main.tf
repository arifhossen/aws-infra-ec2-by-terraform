# codebuild.tf
# Data source to get current AWS region
data "aws_region" "current" {}

# Data source to get current account ID
data "aws_caller_identity" "current" {}


# AWS CodeBuild project for building Docker images
resource "aws_codebuild_project" "app_build" {
  name          = "${var.project_name}_${var.stage}-build"
  description   = "Build project for ${var.project_name}"
  build_timeout = var.codebuild_timeout
  service_role  = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true # Required for Docker builds

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_app_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.stage
    }

    # Add any additional environment variables your build needs
    environment_variable {
      name  = "BUILD_ENV"
      value = var.stage
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.aws_cloudwatch_log_group_codebuild_logs_name
      stream_name = "build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  # Uncomment if CodeBuild needs to run in a VPC
  # vpc_config {
  #   vpc_id             = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default.id
  #   subnets            = var.subnet_ids
  #   security_group_ids = [aws_security_group.codebuild[0].id]
  # }

  tags = {
    Name = "${var.project_name}_${var.stage}-build"
  }
}

# Optional: Security group for CodeBuild if running in VPC
# resource "aws_security_group" "codebuild" {
#   count       = var.vpc_id != "" ? 1 : 0
#   name        = "${var.project_name}-codebuild-sg"
#   description = "Security group for CodeBuild"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-codebuild-sg"
#   }
# }

# CloudWatch Event Rule to trigger build on ECR image push (optional)
resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  count       = 0 # Set to 1 to enable
  name        = "${var.project_name}_${var.stage}-ecr-image-push"
  description = "Trigger on ECR image push"

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
      repository-name = [var.ecr_repository_app_name]
    }
  })
}

# CloudWatch Metric Alarm for build failures
# resource "aws_cloudwatch_metric_alarm" "build_failed" {
#   count               = var.enable_monitoring ? 1 : 0
#   alarm_name          = "${var.project_name}-build-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "FailedBuilds"
#   namespace           = "AWS/CodeBuild"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = 0
#   alarm_description   = "Alert when CodeBuild fails"
#   treat_missing_data  = "notBreaching"

#   dimensions = {
#     ProjectName = aws_codebuild_project.app_build.name
#   }

#   alarm_actions = var.notification_email != "" ? [aws_sns_topic.notifications[0].arn] : []

#   tags = {
#     Name = "${var.project_name}-build-failed-alarm"
#   }
# }
