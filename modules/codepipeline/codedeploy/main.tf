# codedeploy.tf
# AWS CodeDeploy application and deployment group

resource "aws_codedeploy_app" "app" {
  name             = var.project_name
  compute_platform = "Server"

  tags = {
    Name = "${var.project_name}-codedeploy-app"
  }
}

# SNS Topic for notifications (module-scoped)
resource "aws_sns_topic" "notifications" {
  count = var.notification_email != "" ? 1 : 0
  name  = "${var.project_name}-codedeploy-notifications"

  tags = {
    Name = "${var.project_name}-codedeploy-notifications"
  }
}

resource "aws_sns_topic_subscription" "notifications" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_codedeploy_deployment_group" "app" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "${var.stage}-deployment-group"
  service_role_arn       = var.codedeploy_role_arn
  deployment_config_name = var.deployment_config_name

  # Target EC2 instances by tags
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.project_name}-server"
    }

    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = var.stage
    }
  }

  # Auto rollback configuration
  auto_rollback_configuration {
    enabled = var.enable_auto_rollback
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  # Deployment style
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  # Optional: Load balancer info (uncomment if using ALB/ELB)
  # load_balancer_info {
  #   target_group_info {
  #     name = aws_lb_target_group.app[0].name
  #   }
  # }

  # Optional: Alarm configuration for automatic rollback
  # alarm_configuration {
  #   alarms  = [aws_cloudwatch_metric_alarm.app_health[0].alarm_name]
  #   enabled = true
  # }

  # Optional: Trigger configuration for SNS notifications
  dynamic "trigger_configuration" {
    for_each = var.notification_email != "" ? [1] : []
    content {
      trigger_events = [
        "DeploymentStart",
        "DeploymentSuccess",
        "DeploymentFailure",
        "DeploymentStop",
        "DeploymentRollback"
      ]
      trigger_name       = "${var.project_name}-deployment-trigger"
      trigger_target_arn = aws_sns_topic.notifications[0].arn
    }
  }

  tags = {
    Name = "${var.project_name}-${var.stage}-deployment-group"
  }

  depends_on = [
    aws_codedeploy_app.app
  ]
}

# Optional: Auto Scaling Group integration
# Uncomment if using Auto Scaling
# resource "aws_codedeploy_deployment_group" "app_asg" {
#   count                  = var.auto_scaling_enabled ? 1 : 0
#   app_name               = aws_codedeploy_app.app.name
#   deployment_group_name  = "${var.environment}-asg-deployment-group"
#   service_role_arn       = aws_iam_role.codedeploy_role.arn
#   deployment_config_name = var.deployment_config_name

#   auto_scaling_groups = [aws_autoscaling_group.app[0].name]

#   auto_rollback_configuration {
#     enabled = var.enable_auto_rollback
#     events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
#   }

#   deployment_style {
#     deployment_option = "WITH_TRAFFIC_CONTROL"
#     deployment_type   = "BLUE_GREEN"
#   }

#   blue_green_deployment_config {
#     terminate_blue_instances_on_deployment_success {
#       action                           = "TERMINATE"
#       termination_wait_time_in_minutes = 5
#     }

#     deployment_ready_option {
#       action_on_timeout = "CONTINUE_DEPLOYMENT"
#     }

#     green_fleet_provisioning_option {
#       action = "COPY_AUTO_SCALING_GROUP"
#     }
#   }

#   load_balancer_info {
#     target_group_info {
#       name = aws_lb_target_group.app[0].name
#     }
#   }

#   tags = {
#     Name = "${var.project_name}-${var.environment}-asg-deployment-group"
#   }
# }

# CloudWatch Metric Alarm for deployment failures
resource "aws_cloudwatch_metric_alarm" "deployment_failed" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.project_name}-deployment-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedDeployments"
  namespace           = "AWS/CodeDeploy"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert when CodeDeploy deployment fails"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApplicationName     = aws_codedeploy_app.app.name
    DeploymentGroupName = aws_codedeploy_deployment_group.app.deployment_group_name
  }

  alarm_actions = var.notification_email != "" ? [aws_sns_topic.notifications[0].arn] : []

  tags = {
    Name = "${var.project_name}-deployment-failed-alarm"
  }
}
