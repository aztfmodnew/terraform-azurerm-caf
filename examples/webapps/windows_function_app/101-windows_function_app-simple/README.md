# Windows Function App Example

This example demonstrates how to deploy a Windows Function App using the modern `windows_function_apps` resource in the Azure CAF Terraform framework.

## Features

- Windows Function App with .NET 6.0 runtime
- Storage Account for Function App storage
- Service Plan with consumption (Y1) SKU
- Modern resource configuration with separated tfvars files

## Resources Created

- Resource Group
- Service Plan (Windows, Y1 SKU)
- Storage Account
- Windows Function App

## Usage

Deploy the example from the `/examples` directory:

```bash
terraform init
terraform plan \
  -var-file=./webapps/function_app/103-function_app-windows/resource_groups.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/service_plans.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/storage_accounts.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/windows_function_apps.tfvars

terraform apply \
  -var-file=./webapps/function_app/103-function_app-windows/resource_groups.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/service_plans.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/storage_accounts.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/windows_function_apps.tfvars
```

## Configuration

The example includes:

- **Resource Groups**: Basic resource group configuration
- **Service Plans**: Windows-based App Service Plan with consumption pricing
- **Storage Accounts**: Standard LRS storage for Function App requirements
- **Windows Function Apps**: .NET 6.0 Function App with basic configuration

## Migration Notes

This example replaces the deprecated `function_apps` resource with the modern `windows_function_apps` resource, providing:

- Better separation of concerns with individual tfvars files
- Modern resource schema alignment
- CAF naming compliance
- Enhanced feature support

## Cleanup

```bash
terraform destroy \
  -var-file=./webapps/function_app/103-function_app-windows/resource_groups.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/service_plans.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/storage_accounts.tfvars \
  -var-file=./webapps/function_app/103-function_app-windows/windows_function_apps.tfvars
```
