# Linux Web App - Extended Configuration Example

This example demonstrates how to deploy a Linux Web App with extended configuration options including:

- System-assigned managed identity
- Custom application stack (Python 3.8)
- IP restrictions for both main site and SCM
- CORS configuration
- Storage account mounts
- Connection strings
- Custom app settings

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- CAF Terraform provider configured

## Resources Created

- Resource Group
- App Service Plan (Linux, P1v2)
- Linux Web App with extended configuration

## Configuration Files

- `resource_groups.tfvars` - Resource group configuration
- `service_plans.tfvars` - App Service Plan configuration
- `linux_web_apps.tfvars` - Linux Web App configuration

## Deployment

Navigate to the examples directory and run:

```bash
cd /path/to/terraform-azurerm-caf/examples

terraform init
terraform plan \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/linux_web_apps.tfvars

terraform apply \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/linux_web_apps.tfvars
```

## Cleanup

```bash
terraform destroy \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/103-linux_web_app-extend/linux_web_apps.tfvars
```

## Features Demonstrated

- **IP Restrictions**: Configure IP-based access control
- **CORS**: Enable cross-origin resource sharing
- **Storage Mounts**: Mount Azure storage accounts
- **Connection Strings**: Database connection configuration
- **Application Stack**: Python runtime configuration
- **Security**: System-assigned managed identity
