# AWS CodePipeline CI/CD Infrastructure with Terraform

A complete Infrastructure-as-Code (IaC) solution for deploying a fully automated CI/CD pipeline on AWS using Terraform. This project provisions EC2 instances, AWS CodePipeline, CodeBuild, CodeDeploy, ECR, and supporting services for continuous integration and deployment.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [CI/CD Pipeline Flow](#cicd-pipeline-flow)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

---

## 🏗️ Overview

This project automates the deployment of a complete CI/CD infrastructure on AWS:

- **Source Control Integration**: Connects to GitHub repositories via CodeStar Connections
- **Continuous Integration**: Builds Docker images using AWS CodeBuild
- **Container Registry**: Stores images in Amazon ECR
- **Continuous Deployment**: Deploys to EC2 instances using AWS CodeDeploy
- **Infrastructure**: VPC, Security Groups, Load Balancers, IAM roles, KMS encryption
- **Monitoring**: CloudWatch logs, SNS notifications, CloudWatch alarms

---

## 🎯 Architecture

```
GitHub Repository
    ↓
CodePipeline (Source Stage)
    ↓
CodeBuild (Build & Push Docker Image)
    ↓
ECR (Container Registry)
    ↓
Manual Approval (Optional)
    ↓
CodeDeploy (Deploy to EC2)
    ↓
EC2 Instances (Running Application)
```

### AWS Services Used

| Service | Purpose |
|---------|---------|
| **CodePipeline** | Orchestrates the CI/CD workflow |
| **CodeBuild** | Builds and pushes Docker images |
| **CodeDeploy** | Deploys application to EC2 instances |
| **ECR** | Stores Docker container images |
| **EC2** | Runs the application |
| **VPC** | Network isolation and security |
| **Load Balancer** | Distributes traffic to EC2 instances |
| **CloudWatch** | Logs and monitoring |
| **SNS** | Email notifications |
| **KMS** | Encryption for artifacts |
| **IAM** | Access control and permissions |

---

## 📦 Prerequisites

### Local Requirements

1. **Terraform** >= 1.0
   ```bash
   terraform --version
   ```

2. **AWS CLI** v2
   ```bash
   aws --version
   ```

3. **Git**
   ```bash
   git --version
   ```

### AWS Requirements

1. **AWS Account** with appropriate permissions
2. **AWS Credentials** configured locally
   ```bash
   aws configure
   # or set AWS_PROFILE environment variable
   export AWS_PROFILE=moonlive
   ```

3. **GitHub Personal Access Token** (for private repositories)
4. **SSH Key Pair** for EC2 access

---

## 📁 Project Structure

```
aws-infra-ec2-by-terraform/
├── README.md                          # Documentation
├── environments/
│   └── dev/
│       ├── main.tf                    # Main Terraform configuration
│       ├── terraform.tfvars           # Environment-specific variables
│       ├── backend.tf                 # Terraform state backend
│       └── variables.tf               # Variable definitions
├── modules/
│   ├── main.tf                        # Root module orchestration
│   ├── provider.tf                    # AWS provider configuration
│   ├── variables.tf                   # Root-level variables
│   ├── vpc/                           # VPC and networking
│   ├── security-group/                # Security group rules
│   ├── ec2/                           # EC2 instances and load balancers
│   ├── s3/                            # S3 bucket for pipeline artifacts
│   ├── iam/                           # IAM roles and policies
│   ├── keypair/                       # EC2 key pairs
│   ├── elastic-ip/                    # Elastic IP addresses
│   ├── cloudwatch-logs/               # CloudWatch log groups
│   └── codepipeline/                  # CI/CD pipeline modules
│       ├── codepipeline/              # CodePipeline orchestration
│       ├── codebuild/                 # CodeBuild configuration
│       ├── codedeploy/                # CodeDeploy configuration
│       ├── ecr/                       # ECR repository
│       └── iam/                       # Pipeline IAM roles
└── python-ec2-ecr-cicd/               # Application code
    ├── app.py                         # Python application
    ├── Dockerfile                     # Docker image definition
    ├── buildspec.yml                  # CodeBuild specification
    ├── appspec.yml                    # CodeDeploy specification
    └── scripts/                       # Deployment scripts
```

---

## 🚀 Setup Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/arifhossen/aws-infra-ec2-by-terraform.git
cd aws-infra-ec2-by-terraform
```

### Step 2: Initialize Terraform

```bash
cd environments/dev
terraform init
```

### Step 3: Configure AWS Credentials

```bash
export AWS_PROFILE=moonlive
# or
aws configure
```

### Step 4: Review Variables

Edit `environments/dev/terraform.tfvars`:

```hcl
region       = "us-east-1"
stage        = "dev"
organization = "cicd"
project_name = "testapp"

github_repo_owner = "arifhossen"
github_repo_name  = "python-ec2-ecr-cicd"
github_branch     = "main"

ami_id        = "ami-0ecb62995f68bb549"
instance_type = "t2.medium"

domain_name     = "cicd-testapp-dev.graaho.net"
notification_email = "your-email@example.com"
```

---

## ⚙️ Configuration

### Key Variables

| Variable | Description |
|----------|-------------|
| `region` | AWS region |
| `stage` | Environment (dev/staging/prod) |
| `project_name` | Project identifier |
| `github_repo_owner` | GitHub account |
| `github_repo_name` | GitHub repository |
| `instance_type` | EC2 instance type |
| `notification_email` | Email for alerts |

---

## 📦 Deployment

### Step 1: Plan

```bash
cd environments/dev
terraform plan -lock=false
```

### Step 2: Apply

```bash
terraform apply -lock=false
```

**Deployment Time**: ~10-15 minutes

### Step 3: Authorize GitHub Connection

1. Go to **AWS Console** → **Developer Tools** → **Connections**
2. Find your CodeStar connection
3. Click **Update pending connection**
4. Authorize GitHub access

### Step 4: Verify

```bash
terraform output
terraform output instance_id
terraform output ec2_name
```

---

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `ec2_name` | EC2 instance name |
| `instance_ip` | EC2 public IP |
| `load_balancer_dns` | Load balancer DNS |
| `ecr_repository_url` | ECR repository URL |
| `codepipeline_url` | CodePipeline URL |
| `s3_bucket_name` | S3 bucket name |

---

## 🔄 CI/CD Pipeline Flow

### Pipeline Stages

1. **Source** - GitHub checkout
2. **Build** - Docker build & ECR push
3. **Approval** - Manual approval (optional)
4. **Deploy** - CodeDeploy to EC2

### Monitoring

```bash
# Pipeline status
aws codepipeline get-pipeline-state --name testapp-pipeline

# Build logs
aws logs tail /aws/codebuild/testapp-build --follow

# Deploy logs
ssh -i ~/.ssh/key.pem ubuntu@<ip>
sudo tail -f /var/log/codedeploy-agent/codedeploy-agent.log
```

---

## 🔐 Security Features

- VPC isolation
- Security groups with restricted rules
- KMS encryption for artifacts
- IAM roles with least privilege
- SSH key-pair access
- SSL/TLS via ACM certificate
- SNS email notifications

---

## 🐛 Troubleshooting

### CodePipeline Source Fails

**Error**: "Failed to authorize connection"

**Solution**: Re-authorize in AWS Console → Connections

### CodeBuild Cannot Push to ECR

**Error**: "AccessDenied: kms:Decrypt"

**Solution**: KMS permissions already included in IAM policy

### CodeDeploy Finds No Instances

**Error**: "No instances found for deployment"

**Solution**: Verify EC2 tags:

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=cicd-testapp-dev"
```

Add tags if missing:

```bash
aws ec2 create-tags --resources i-xxxxx \
  --tags Key=Name,Value=cicd-testapp-dev Key=Environment,Value=dev
```

### Terraform State Locked

```bash
terraform force-unlock <LOCK_ID>
```

---

## 📊 Monitoring

### CloudWatch Logs

```bash
aws logs describe-log-groups --query 'logGroups[*].logGroupName'
aws logs tail /aws/codebuild/testapp-build --follow
```

### CloudWatch Alarms

```bash
aws cloudwatch describe-alarms --alarm-names testapp-pipeline-failed
```

### SNS Notifications

Receive alerts for:
- Pipeline execution started/succeeded/failed
- Manual approval needed
- Deployment events

---

## 🧹 Cleanup

```bash
cd environments/dev
terraform destroy -lock=false
```

**Warning**: This deletes all resources including:
- EC2 instances
- Load balancers
- VPC and subnets
- IAM roles
- S3 buckets (if empty)
- All other AWS resources

---

## 📝 Usage Tips

### Push Code Changes

```bash
cd ../python-ec2-ecr-cicd
# Make changes
git add .
git commit -m "Update application"
git push origin main
# Pipeline triggers automatically
```

### Scale to Production

1. Create `environments/prod/terraform.tfvars`
2. Update `instance_type` to larger size
3. Change `stage = "prod"`
4. Deploy in separate AWS account (recommended)

### Add More Environments

```bash
cp -r environments/dev environments/staging
cd environments/staging
terraform init
terraform apply
```

---

## 📚 Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CodePipeline](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Buildspec](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
- [AWS CodeDeploy AppSpec](https://docs.aws.amazon.com/codedeploy/latest/userguide/app-spec-ref.html)

---

## 👥 Contributing

1. Create a feature branch
2. Test with `terraform plan`
3. Submit pull request

---

## 📄 License

This project is provided as-is for educational and commercial use.

---

## 🤝 Support

For issues:

1. Check [Troubleshooting](#troubleshooting)
2. Review CloudWatch logs
3. Check Terraform state: `terraform show`
4. Create an issue in the repository

---

## 🎯 Next Steps After Deployment

1. ✅ Verify EC2 instance is running
2. ✅ Authorize GitHub connection
3. ✅ Push code to GitHub
4. ✅ Monitor CodeBuild and CodeDeploy
5. ✅ Access application via load balancer
6. ✅ Verify CloudWatch logs
7. ✅ Test manual approval (if enabled)

---

**Last Updated**: November 16, 2025
**Project**: AWS CodePipeline CI/CD Infrastructure
**Author**: Arif Hossen
**Repository**: https://github.com/arifhossen/aws-infra-ec2-by-terraform



Documentation:
