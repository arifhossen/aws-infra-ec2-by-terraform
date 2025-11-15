# Terraform Project

## Deploying Dev Infrastructure

To set up the **Dev** environment, navigate to the `environments/dev` folder and run the following commands:

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Resolving Lock Issues
# If you encounter a lock file issue, use the following command
```bash
terraform init
terraform plan -lock=false
terraform apply -lock=false
```

