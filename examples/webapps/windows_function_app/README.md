# Windows Function App Examples

This directory contains examples for deploying Windows-based Azure Function Apps using the CAF (Cloud Adoption Framework) Terraform modules.

## Available Examples

### 101-windows_function_app-simple

Demonstrates a simple Windows Function App deployment with:

- Windows service plan configuration
- Storage account integration
- .NET runtime configuration
- Basic function app settings

### 102-windows_function_app-private

Demonstrates a secure Windows Function App deployment with:

- **Private Endpoint**: Function app accessible only through private IP
- **VNet Integration**: Outbound traffic routed through VNet
- **Storage Private Endpoints**: Storage accessible only through private network
- **Network Security Groups**: Traffic filtering at subnet level
- **Managed Identity**: Secure authentication to storage without connection strings
- **Zero Trust Architecture**: All resources isolated by default

## Usage

### Simple Example

Navigate to the example directory and run:

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform plan \
  -var-file=./webapps/windows_function_app/101-windows_function_app-simple/resource_groups.tfvars \
  -var-file=./webapps/windows_function_app/101-windows_function_app-simple/service_plans.tfvars \
  -var-file=./webapps/windows_function_app/101-windows_function_app-simple/storage_accounts.tfvars \
  -var-file=./webapps/windows_function_app/101-windows_function_app-simple/windows_function_apps.tfvars \
  -var-file=./webapps/windows_function_app/101-windows_function_app-simple/configuration.tfvars
```

### Private Endpoint Example

For the secure private endpoint deployment:

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform plan \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/global_settings.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/resource_groups.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/service_plans.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/storage_accounts.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/vnets.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/nsg.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/networking.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/private_dns.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/private_endpoints.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/application_insights.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/windows_function_apps.tfvars
```

## Module Information

These examples use the modern `azurerm_windows_function_app` resource through the CAF module:

- **Module Path**: `modules/webapps/windows_function_app/`
- **Resource Type**: `azurerm_windows_function_app`
- **Configuration Block**: `windows_function_apps`

## Requirements

- Windows service plan (`os_type = "Windows"` in service_plans)
- Storage account for function app storage
- Resource group
- .NET or other Windows-compatible runtime

## Key Features

- **Modern Resource**: Uses `azurerm_windows_function_app` (not deprecated `azurerm_function_app`)
- **OS-Specific**: Optimized for Windows runtime environments (.NET, PowerShell, etc.)
- **CAF Compliant**: Follows Azure Cloud Adoption Framework naming and tagging standards
- **Flexible Configuration**: Supports various Windows-specific deployment scenarios
- **Slot Support**: Includes support for deployment slots for staging/production scenarios

## Runtime Support

Windows Function Apps support multiple runtimes:

- **.NET**: v6.0, v8.0 (isolated and in-process)
- **PowerShell**: PowerShell Core versions
- **Node.js**: Various Node.js versions
- **Java**: Java 8, 11, 17
- **Custom**: Custom runtime handlers
