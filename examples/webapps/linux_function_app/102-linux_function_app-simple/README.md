# Linux Function App Example

This example demonstrates how to deploy a Linux Function App using the modern `linux_function_apps` resource in the Azure CAF Terraform framework.

## Features

- Linux Function App with Python 3.9 runtime
- Storage Account for Function App storage
- Service Plan with consumption (Y1) SKU
- Modern resource configuration with separated tfvars files

## Resources Created

- Resource Group
- Service Plan (Linux, Y1 SKU)
- Storage Account
- Linux Function App

## Usage

Deploy the example from the `/examples` directory:

```bash
terraform init
terraform plan \
  -var-file=./webapps/function_app/102-function_app-linux/resource_groups.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/service_plans.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/storage_accounts.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/linux_function_apps.tfvars

terraform apply \
  -var-file=./webapps/function_app/102-function_app-linux/resource_groups.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/service_plans.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/storage_accounts.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/linux_function_apps.tfvars
```

## Configuration

The example includes:

- **Resource Groups**: Basic resource group configuration
- **Service Plans**: Linux-based App Service Plan with consumption pricing
- **Storage Accounts**: Standard LRS storage for Function App requirements
- **Linux Function Apps**: Python 3.9 Function App with basic configuration

## Migration Notes

This example replaces the deprecated `function_apps` resource with the modern `linux_function_apps` resource, providing:

- Better separation of concerns with individual tfvars files
- Modern resource schema alignment
- CAF naming compliance
- Enhanced feature support

## Cleanup

```bash
terraform destroy \
  -var-file=./webapps/function_app/102-function_app-linux/resource_groups.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/service_plans.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/storage_accounts.tfvars \
  -var-file=./webapps/function_app/102-function_app-linux/linux_function_apps.tfvars
```
