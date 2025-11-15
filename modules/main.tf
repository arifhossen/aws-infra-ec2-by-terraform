
#VPC Module
module "vpc" {
  source                      = "./vpc"
  cidr_block                  = var.cidr_block
  public_subnet_1_cidr        = var.public_subnet_1_cidr
  public_subnet_2_cidr        = var.public_subnet_2_cidr
  private_subnet_1_cidr       = var.private_subnet_1_cidr
  private_subnet_2_cidr       = var.private_subnet_2_cidr
  public_route_tbl_cidr_block = var.public_route_tbl_cidr_block
  availability_zone_1         = var.availability_zone_1
  availability_zone_2         = var.availability_zone_2
  stage                       = var.stage
  organization                = var.organization
  project_name                = var.project_name
}
# Security Group Module
module "security_group" {
  source       = "./security-group"
  vpc_id       = module.vpc.vpc_id
  stage        = var.stage
  organization = var.organization
  project_name = var.project_name
}

# Key Pair for EC2
module "keypair" {
  source       = "./keypair"
  stage        = var.stage
  organization = var.organization
  project_name = var.project_name
}

# CloudWatch Logs
module "cloudwatch" {
  source       = "./cloudwatch-logs"
  stage        = var.stage
  organization = var.organization
  project_name = var.project_name
}

# s3
module "s3" {
  source       = "./s3"
  stage        = var.stage
  organization = var.organization
  project_name = var.project_name
}


# Iam
module "iam" {
  source                = "./iam"
  stage                 = var.stage
  organization          = var.organization
  project_name          = var.project_name
  github_connection_arn = var.github_connection_arn
  notification_email    = var.notification_email
  artifacts_bucket_arn  = module.s3.artifacts_bucket_arn
}

# EC2
module "ec2" {
  source                  = "./ec2"
  stage                   = var.stage
  organization_name       = var.organization
  project_name            = var.project_name
  ami_id                  = var.ami_id
  key_name                = module.keypair.key_name
  vpc_id                  = module.vpc.vpc_id
  instance_type           = var.instance_type
  subnet_ids              = [module.vpc.public_subnet_1, module.vpc.public_subnet_2]
  security_group_id       = module.security_group.ec2_sg_id
  security_group_name     = module.security_group.ec2_sg_name
  alb_security_group_id   = module.security_group.alb_sg_id
  alb_security_group_name = module.security_group.alb_sg_name
  domain_name             = var.domain_name
  route53_zone_id         = var.route53_zone_id
  acm_certificate_arn     = var.acm_certificate_arn
  ec2_iam_profile_name    = module.iam.ec2_instance_profile_name

}

# Elastic IP
module "eip" {
  source       = "./elastic-ip"
  stage        = var.stage
  organization = var.organization
  project_name = var.project_name
  instance_id  = module.ec2.instance_id
}


# AWS Pipeline: ECR
module "ecr" {
  source       = "./codepipeline/ecr"
  stage        = var.stage
  organization = var.organization
  project_name = var.project_name


}


# AWS Pipeline: Codebuild
module "awscodebuild" {
  source                  = "./codepipeline/codebuild"
  stage                   = var.stage
  organization            = var.organization
  project_name            = var.project_name
  notification_email      = var.notification_email
  codebuild_role_arn      = module.iam.codebuild_iam_role_arn
  ecr_repository_app_name = module.ecr.ecr_repository_name
}


# AWS Pipeline: CodeDeploy
module "awscodeDeploy" {
  source                 = "./codepipeline/codedeploy"
  stage                  = var.stage
  organization           = var.organization
  project_name           = var.project_name
  notification_email     = var.notification_email
  codedeploy_role_arn    = module.iam.codedeploy_iam_role_arn
  deployment_config_name = var.deployment_config_name
}


# AWS Pipeline: CodePipeline
module "awscodepipeline" {
  source                                   = "./codepipeline/codepipeline"
  stage                                    = var.stage
  organization                             = var.organization
  project_name                             = var.project_name
  notification_email                       = var.notification_email
  aws_codebuild_project_name               = module.awscodebuild.codebuild_project_name
  aws_codedeploy_app_name                  = module.awscodeDeploy.codedeploy_app_name
  aws_codedeploy_app_deployment_group_name = module.awscodeDeploy.codedeploy_deployment_group_name
  artifacts_bucket_arn                     = module.s3.artifacts_bucket_arn
  codepipeline_role_arn                    = module.iam.codepipeline_role_iam_role_arn
  ecr_repository_app_name                  = module.ecr.ecr_repository_name
  github_repo_owner                        = var.github_repo_owner
  github_repo_name                         = var.github_repo_name
  github_branch                            = var.github_branch
  github_connection_arn                    = var.github_connection_arn
  create_github_connection                 = var.create_github_connection
  artifacts_bucket_name                    = module.s3.artifacts_bucket_name

  depends_on = [
    module.iam,
    module.s3,
    module.awscodebuild,
    module.awscodeDeploy
  ]

}
