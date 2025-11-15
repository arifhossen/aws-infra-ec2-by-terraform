# iam.tf
# IAM roles and policies for CI/CD pipeline

# ============================================================================
# CodePipeline IAM Role and Policies
# ============================================================================

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json

  tags = {
    Name = "${var.project_name}-codepipeline-role"
  }
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.project_name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  # S3 permissions for artifacts
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      var.artifacts_bucket_arn,
      "${var.artifacts_bucket_arn}/*"
    ]
  }

  # CodeBuild permissions
  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]

    #   resources = [
    #     aws_codebuild_project.app_build.arn
    #   ]

    resources = ["*"]
  }

  # CodeDeploy permissions
  statement {
    effect = "Allow"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]

    # resources = [
    #   "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application:${aws_codedeploy_app.app.name}",
    #   "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentgroup:${aws_codedeploy_app.app.name}/*",
    #   "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentconfig:*"
    # ]

    resources = ["*"]
  }

  # CodeStar Connections (GitHub)
  statement {
    effect = "Allow"

    actions = [
      "codestar-connections:UseConnection"
    ]

    # resources = [
    #   var.github_connection_arn != "" ? var.github_connection_arn : aws_codestarconnections_connection.github[0].arn
    # ]

    resources = ["*"]
  }

  # IAM PassRole (required for CodePipeline to pass roles to other services)
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  # KMS permissions for artifact encryption/decryption
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }
}

# ============================================================================
# CodeBuild IAM Role and Policies
# ============================================================================

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = {
    Name = "${var.project_name}-codebuild-role"
  }
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.project_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

data "aws_iam_policy_document" "codebuild_policy" {
  # CloudWatch Logs
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    # resources = [
    #   "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}-build",
    #   "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}-build:*"
    # ]

    resources = ["*"]
  }

  # S3 - Artifacts
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
    ]

    # resources = [
    #   aws_s3_bucket.pipeline_artifacts.arn,
    #   "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    # ]

    resources = ["*"]
  }

  # ECR - Full access for pushing images
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    # resources = [
    #   aws_ecr_repository.app.arn
    # ]

    resources = ["*"]
  }

  # Secrets Manager (optional - if using secrets in build)
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    # resources = [
    #   "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*"
    # ]

    resources = ["*"]
  }

  # VPC permissions (if CodeBuild needs VPC access)
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission"
    ]

    resources = ["*"]
  }

  # KMS permissions for artifact decryption
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }
}

# ============================================================================
# CodeDeploy IAM Role and Policies
# ============================================================================

resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.project_name}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json

  tags = {
    Name = "${var.project_name}-codedeploy-role"
  }
}

data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policy for CodeDeploy
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role = aws_iam_role.codedeploy_role.name
  # Use the service-role path for the managed CodeDeploy role policy
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Additional CodeDeploy permissions
resource "aws_iam_role_policy" "codedeploy_additional_policy" {
  name   = "${var.project_name}-codedeploy-additional-policy"
  role   = aws_iam_role.codedeploy_role.id
  policy = data.aws_iam_policy_document.codedeploy_additional_policy.json
}

data "aws_iam_policy_document" "codedeploy_additional_policy" {
  # S3 access for deployment artifacts
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket"
    ]

    # resources = [
    #   aws_s3_bucket.pipeline_artifacts.arn,
    #   "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    # ]

    resources = ["*"]
  }

  # SNS for notifications (optional)
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = ["*"]
  }
}

# ============================================================================
# EC2 Instance Profile and Role
# ============================================================================

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Additional EC2 permissions
resource "aws_iam_role_policy" "ec2_additional_policy" {
  name   = "${var.project_name}-ec2-additional-policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_additional_policy.json
}

data "aws_iam_policy_document" "ec2_additional_policy" {
  # S3 access for deployment artifacts
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    # resources = [
    #   aws_s3_bucket.pipeline_artifacts.arn,
    #   "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    # ]

    resources = ["*"]
  }

  # Secrets Manager access
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    # resources = [
    #   "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*"
    # ]

    resources = [
      "*"
    ]
  }

  # CloudWatch Logs
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    # resources = [
    #   "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}",
    #   "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}:*"
    # ]

    resources = [
      "*"
    ]
  }

  # SSM Parameter Store (for configuration)
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    # resources = [
    #   "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/*"
    # ]

    resources = [
      "*"
    ]
  }

  # ECR for pulling images (enhanced permissions)
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]


    resources = [
      "*"
    ]
  }

  # EC2 describe for getting instance metadata
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]

    resources = ["*"]
  }
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "${var.project_name}-ec2-profile"
  }
}

# ============================================================================
# SNS Topic for Notifications (Optional)
# ============================================================================

resource "aws_iam_role" "sns_role" {
  count              = var.notification_email != "" ? 1 : 0
  name               = "${var.project_name}-sns-role"
  assume_role_policy = data.aws_iam_policy_document.sns_assume_role[0].json

  tags = {
    Name = "${var.project_name}-sns-role"
  }
}

data "aws_iam_policy_document" "sns_assume_role" {
  count = var.notification_email != "" ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "sns_policy" {
  count  = var.notification_email != "" ? 1 : 0
  name   = "${var.project_name}-sns-policy"
  role   = aws_iam_role.sns_role[0].id
  policy = data.aws_iam_policy_document.sns_policy[0].json
}

data "aws_iam_policy_document" "sns_policy" {
  count = var.notification_email != "" ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = ["*"]
  }
}
