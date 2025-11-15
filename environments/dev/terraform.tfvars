region       = "us-east-1"
stage        = "dev"
aws_profile  = "moonlive"
organization = "cicd"
project_name = "testapp"

#EC2 Ubuntu machine info
ami_id        = "ami-0ecb62995f68bb549" # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250610
instance_type = "t2.medium"

cidr_block = "10.0.0.0/16"
#Public Subnet CIDR Information
public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"

#Private Subnet CIDR Information
private_subnet_1_cidr = "10.0.3.0/24"
private_subnet_2_cidr = "10.0.4.0/24"

#Route Table CIDR Information
public_route_tbl_cidr_block = "0.0.0.0/0"

#Availability Zone Information
availability_zone_1 = "us-east-1a"
availability_zone_2 = "us-east-1b"

#ACM Certificate arn
acm_certificate_arn = "arn:aws:acm:us-east-1:835233526797:certificate/67f89ef4-16b6-49c9-a64d-1c025e6ce7cb"

#Route 53 Zone ID
route53_zone_id = "Z00975912RL752OVTU9DD" # Hosted zone name: graaho.net

#Domain name
domain_name          = "cicd-testapp-dev.graaho.net"
frontend_domain_name = ""
notification_email   = "arif.hossen@graaho.com"




# ============================================================================
# Required Variables
# ============================================================================

# GitHub Configuration
github_repo_owner = "arifhossen"
github_repo_name  = "python-ec2-ecr-cicd"
github_branch     = "main"


# ============================================================================
# GitHub Connection
# ============================================================================

# Option 1: Create new connection (requires manual OAuth authorization)
create_github_connection = true
github_connection_arn    = "" # Leave empty to create new

# Option 2: Use existing connection ARN
# create_github_connection = false
# github_connection_arn    = "arn:aws:codestar-connections:us-east-1:123456789012:connection/xxxxx"

# ============================================================================
# ECR Configuration
# ============================================================================

ecr_image_tag_mutability    = "MUTABLE" # MUTABLE or IMMUTABLE
ecr_scan_on_push            = true      # Enable image vulnerability scanning
enable_ecr_lifecycle_policy = true      # Remove old images automatically
ecr_image_retention_count   = 10        # Keep last N images

# ============================================================================
# CodeBuild Configuration
# ============================================================================

codebuild_compute_type = "BUILD_GENERAL1_SMALL" # BUILD_GENERAL1_SMALL, MEDIUM, LARGE
codebuild_image        = "aws/codebuild/standard:7.0"
codebuild_timeout      = 60 # Build timeout in minutes






