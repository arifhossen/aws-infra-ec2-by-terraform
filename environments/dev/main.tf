module "server_infra" {
  source = "../../modules"

  stage                       = var.stage
  region                      = var.region
  organization                = var.organization
  project_name                = var.project_name
  aws_profile                 = var.aws_profile
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  private_subnet_1_cidr       = var.private_subnet_1_cidr
  private_subnet_2_cidr       = var.private_subnet_2_cidr
  availability_zone_1         = var.availability_zone_1
  availability_zone_2         = var.availability_zone_2
  public_route_tbl_cidr_block = var.public_route_tbl_cidr_block
  cidr_block                  = var.cidr_block
  public_subnet_1_cidr        = var.public_subnet_1_cidr
  public_subnet_2_cidr        = var.public_subnet_2_cidr
  domain_name                 = var.domain_name
  acm_certificate_arn         = var.acm_certificate_arn
  route53_zone_id             = var.route53_zone_id
  frontend_domain_name        = var.frontend_domain_name
  notification_email          = var.notification_email
  github_repo_owner           = var.github_repo_owner
  github_repo_name            = var.github_repo_name


}


