# AWS CodePipeline Terraform Module: Step-by-Step Guide

This module automates CI/CD for your application using AWS CodePipeline, CodeBuild, CodeDeploy, and integrates notifications and monitoring.

---

## 1. Prerequisites
- S3 bucket for pipeline artifacts
- IAM roles for CodePipeline, CodeBuild, CodeDeploy
- GitHub repository and CodeStar Connection ARN
- Email for notifications (optional)

---

## 2. Main Resources and Flow

### a. Data Sources
- `aws_region.current`: Gets the current AWS region.
- `aws_caller_identity.current`: Gets the AWS account ID.

### b. GitHub Connection
- Creates a CodeStar Connection to GitHub if ARN is not provided.
- **Manual Step:** Authorize the connection in AWS Console after creation.

### c. SNS Notifications
- Creates an SNS topic and email subscription if a notification email is provided.
- Used for pipeline state change alerts and manual approval notifications.

### d. KMS Key
- Creates a KMS key for encrypting pipeline artifacts in S3.

### e. CodePipeline Stages

#### 1. Source Stage
- Pulls code from GitHub using CodeStar Connection.
- Outputs artifact: `SourceOutput`.

#### 2. Build Stage
- Uses AWS CodeBuild to build the source artifact.
- Outputs artifact: `BuildOutput`.

#### 3. Manual Approval Stage (Optional)
- If enabled, sends a manual approval request before deployment.
- Notifies via SNS if configured.

#### 4. Deploy Stage
- Deploys the built artifact using AWS CodeDeploy to target EC2 instances.

### f. Monitoring and Notifications
- **CloudWatch Events:** Triggers notifications on pipeline state changes.
- **SNS Topic Policy:** Allows CloudWatch Events and CodeStar Notifications to publish to SNS.
- **CodeStar Notification Rule:** Sends notifications for pipeline execution failures, successes, and manual approval needs.
- **CloudWatch Metric Alarm:** Alerts when pipeline execution fails.
- **CloudWatch Dashboard:** Visualizes pipeline, build, and deployment metrics.

---

## 3. How It Works (Step-by-Step)

**Source Stage:**
CodePipeline fetches the latest code from your GitHub repo using CodeStar Connection.

**Build Stage:**
CodeBuild compiles/tests the code. Output is stored in S3 (encrypted with KMS).

**Manual Approval (Optional):**
If enabled, an approver receives an email and must approve before deployment proceeds.

**Deploy Stage:**
CodeDeploy deploys the build artifact to EC2 instances (filtered by tags).

**Notifications:**
SNS sends emails for pipeline failures, successes, and manual approval requests.

**Monitoring:**
CloudWatch alarms and dashboards provide visibility into pipeline health and execution metrics.

---

## 4. Customization
- Set `enable_manual_approval` to `true` to require manual approval.
- Provide `notification_email` to receive pipeline alerts.
- Adjust `artifacts_bucket_name`, `github_connection_arn`, and other variables as needed.

---

## 5. Manual Steps
- After creating the CodeStar Connection, authorize it in the AWS Console.
- Confirm email subscription for SNS notifications.

---

## 6. Troubleshooting
- Ensure IAM roles have correct permissions (especially for KMS, S3, CodeBuild, CodeDeploy).
- Check that EC2 instances have tags matching CodeDeploy deployment group filters.
- Validate that the S3 bucket exists and is accessible.
