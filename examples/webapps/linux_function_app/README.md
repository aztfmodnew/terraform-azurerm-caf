# Linux Function App Examples

This directory contains examples for deploying Linux-based Azure Function Apps using the CAF (Cloud Adoption Framework) Terraform modules.

## Available Examples

### 101-linux_function_app-private

Demonstrates deploying a Linux Function App with:

- Private networking (VNet integration)
- Storage account integration
- Service plan configuration
- Network security groups

### 102-linux_function_app-simple

Demonstrates a simple Linux Function App deployment with:

- Basic service plan configuration
- Storage account integration
- Minimal configuration for getting started

## Usage

Navigate to any example directory and run:

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

# For the private example
terraform plan \
  -var-file=./webapps/linux_function_app/101-linux_function_app-private/resource_groups.tfvars \
  -var-file=./webapps/linux_function_app/101-linux_function_app-private/service_plans.tfvars \
  -var-file=./webapps/linux_function_app/101-linux_function_app-private/storage_accounts.tfvars \
  -var-file=./webapps/linux_function_app/101-linux_function_app-private/configuration.tfvars

# For the simple example
terraform plan \
  -var-file=./webapps/linux_function_app/102-linux_function_app-simple/resource_groups.tfvars \
  -var-file=./webapps/linux_function_app/102-linux_function_app-simple/service_plans.tfvars \
  -var-file=./webapps/linux_function_app/102-linux_function_app-simple/storage_accounts.tfvars \
  -var-file=./webapps/linux_function_app/102-linux_function_app-simple/configuration.tfvars
```

## Module Information

These examples use the modern `azurerm_linux_function_app` resource through the CAF module:

- **Module Path**: `modules/webapps/linux_function_app/`
- **Resource Type**: `azurerm_linux_function_app`
- **Configuration Block**: `linux_function_apps`

## Requirements

- Linux service plan (`os_type = "Linux"` in service_plans)
- Storage account for function app storage
- Resource group
- Appropriate networking configuration (for private examples)

## Key Features

- **Modern Resource**: Uses `azurerm_linux_function_app` (not deprecated `azurerm_function_app`)
- **OS-Specific**: Optimized for Linux runtime environments
- **CAF Compliant**: Follows Azure Cloud Adoption Framework naming and tagging standards
- **Flexible Configuration**: Supports various deployment scenarios from simple to complex
