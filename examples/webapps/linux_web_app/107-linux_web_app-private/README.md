# Linux Web App - Private Endpoint Example

This example demonstrates how to deploy a Linux Web App with VNet integration and private endpoints for secure network connectivity.

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- CAF Terraform provider configured

## Resources Created

- Resource Groups (webapp and networking)
- Virtual Network with subnets
- Network Security Group
- App Service Plan (Linux, P1v2)
- Linux Web App with VNet integration
- Private Endpoint for secure connectivity

## Configuration Files

- `resource_groups.tfvars` - Resource group configuration
- `networking.tfvars` - Virtual network and subnet configuration
- `service_plans.tfvars` - App Service Plan configuration
- `linux_web_apps.tfvars` - Linux Web App with private endpoint configuration

## Deployment

Navigate to the examples directory and run:

```bash
cd /path/to/terraform-azurerm-caf/examples

terraform init
terraform plan \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/networking.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/linux_web_apps.tfvars

terraform apply \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/networking.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/linux_web_apps.tfvars
```

## Cleanup

```bash
terraform destroy \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/networking.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/107-linux_web_app-private/linux_web_apps.tfvars
```

## Features Demonstrated

- **VNet Integration**: Connect Web App to virtual network
- **Private Endpoints**: Secure private connectivity
- **Network Security**: Network security group configuration
- **Subnet Delegation**: Dedicated subnet for Web App integration
