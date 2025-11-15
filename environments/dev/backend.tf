terraform {
  backend "s3" {
    bucket         = "infra-automation-us-east-1"
    key            = "aws-ec2-infra/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    profile        = "moonlive"
  }
}
