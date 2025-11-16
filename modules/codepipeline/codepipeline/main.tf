# codepipeline.tf
# AWS CodePipeline for CI/CD automation

# Data source to get current AWS region
data "aws_region" "current" {}

# Data source to get current account ID
data "aws_caller_identity" "current" {}

# GitHub Connection (CodeStar Connection)
# Note: This requires manual OAuth authorization in AWS Console after creation
resource "aws_codestarconnections_connection" "github" {
  count         = var.github_connection_arn == "" ? 1 : 0
  name          = "${var.project_name}-github-connection"
  provider_type = "GitHub"

  tags = {
    Name = "${var.project_name}-github-connection"
  }
}

# SNS Topic for notifications
resource "aws_sns_topic" "notifications" {
  count = var.notification_email != "" ? 1 : 0
  name  = "${var.project_name}-pipeline-notifications"

  tags = {
    Name = "${var.project_name}-pipeline-notifications"
  }
}

resource "aws_sns_topic_subscription" "notifications" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# CodePipeline
resource "aws_codepipeline" "app" {
  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.pipeline[0].arn
      type = "KMS"
    }
  }

  # Stage 1: Source from GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        ConnectionArn        = var.github_connection_arn != "" ? var.github_connection_arn : (length(aws_codestarconnections_connection.github) > 0 ? aws_codestarconnections_connection.github[0].arn : "")
        FullRepositoryId     = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  # Stage 2: Build with CodeBuild
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = var.aws_codebuild_project_name
      }
    }
  }

  # Stage 3: Manual Approval (Optional)
  dynamic "stage" {
    for_each = var.enable_manual_approval ? [1] : []
    content {
      name = "Approval"

      action {
        name     = "ManualApproval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          CustomData         = "Please review the build and approve deployment to ${var.stage}"
          NotificationArn    = var.notification_email != "" ? aws_sns_topic.notifications[0].arn : null
          ExternalEntityLink = "https://console.aws.amazon.com/codebuild/home?region=${data.aws_region.current.name}#/projects/${var.aws_codedeploy_app_name}/view"
        }
      }
    }
  }

  # Stage 4: Deploy with CodeDeploy
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["BuildOutput"]

      configuration = {
        ApplicationName     = var.aws_codedeploy_app_name
        DeploymentGroupName = var.aws_codedeploy_app_deployment_group_name
      }
    }
  }

  tags = {
    Name = "${var.project_name}-pipeline"
  }
}

# KMS Key for encrypting pipeline artifacts
resource "aws_kms_key" "pipeline" {
  count               = 1
  description         = "KMS key for ${var.project_name} pipeline artifacts"
  enable_key_rotation = true

  tags = {
    Name = "${var.project_name}-pipeline-kms"
  }
}

resource "aws_kms_alias" "pipeline" {
  count         = 1
  name          = "alias/${var.project_name}-pipeline"
  target_key_id = aws_kms_key.pipeline[0].key_id
}

# CloudWatch Event Rule to trigger pipeline on GitHub push
resource "aws_cloudwatch_event_rule" "pipeline_trigger" {
  count       = 0 # Set to 1 to enable automatic triggering
  name        = "${var.project_name}-pipeline-trigger"
  description = "Trigger pipeline on GitHub push"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state    = ["SUCCEEDED", "FAILED"]
      pipeline = [aws_codepipeline.app.name]
    }
  })
}

# CloudWatch Event Target for SNS notification
resource "aws_cloudwatch_event_target" "pipeline_notification" {
  count     = var.notification_email != "" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.pipeline_state_change[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.notifications[0].arn
}

# CloudWatch Event Rule for pipeline state changes
resource "aws_cloudwatch_event_rule" "pipeline_state_change" {
  count       = var.notification_email != "" ? 1 : 0
  name        = "${var.project_name}-pipeline-state-change"
  description = "Capture pipeline state changes"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state    = ["FAILED", "SUCCEEDED"]
      pipeline = [aws_codepipeline.app.name]
    }
  })

  tags = {
    Name = "${var.project_name}-pipeline-state-change"
  }
}

# SNS Topic Policy to allow CloudWatch Events
resource "aws_sns_topic_policy" "notifications" {
  count  = var.notification_email != "" ? 1 : 0
  arn    = aws_sns_topic.notifications[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = var.notification_email != "" ? 1 : 0

  statement {
    sid    = "AllowCloudWatchEventsPublishTopics"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["SNS:Publish"]

    resources = [aws_sns_topic.notifications[0].arn]
  }

  statement {
    sid    = "AllowCodeStarNotificationsPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    actions = ["SNS:Publish"]

    resources = [aws_sns_topic.notifications[0].arn]
  }
}

# CodePipeline Notification Rule
resource "aws_codestarnotifications_notification_rule" "pipeline" {
  count       = var.notification_email != "" ? 1 : 0
  name        = "${var.project_name}-pipeline-notifications"
  detail_type = "FULL"

  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-manual-approval-needed",
  ]

  resource = aws_codepipeline.app.arn

  target {
    address = aws_sns_topic.notifications[0].arn
  }

  tags = {
    Name = "${var.project_name}-pipeline-notification-rule"
  }
}

# CloudWatch Metric Alarm for pipeline failures
resource "aws_cloudwatch_metric_alarm" "pipeline_failed" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.project_name}-pipeline-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PipelineExecutionFailed"
  namespace           = "AWS/CodePipeline"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when pipeline execution fails"
  treat_missing_data  = "notBreaching"

  dimensions = {
    PipelineName = aws_codepipeline.app.name
  }

  alarm_actions = var.notification_email != "" ? [aws_sns_topic.notifications[0].arn] : []

  tags = {
    Name = "${var.project_name}-pipeline-failed-alarm"
  }
}

# CloudWatch Dashboard for Pipeline Metrics
resource "aws_cloudwatch_dashboard" "pipeline" {
  count          = var.enable_monitoring ? 1 : 0
  dashboard_name = "${var.project_name}-pipeline-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CodePipeline", "PipelineExecutionSuccess", { "stat" : "Sum" }],
            [".", "PipelineExecutionFailed", { "stat" : "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Pipeline Executions"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CodeBuild", "SuccessfulBuilds", { "stat" : "Sum" }],
            [".", "FailedBuilds", { "stat" : "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Build Results"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/CodeDeploy", "SuccessfulDeployments", { "stat" : "Sum" }],
            [".", "FailedDeployments", { "stat" : "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Deployment Results"
        }
      }
    ]
  })
}
