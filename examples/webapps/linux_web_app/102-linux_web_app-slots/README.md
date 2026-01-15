# Linux Web App with Deployment Slots

This example demonstrates how to deploy a Linux Web App with two deployment slots using the CAF split-tfvars pattern.

## Overview

This example creates:

- One Linux Web App instance named `simple_app`
- A main app configuration backed by a Linux App Service plan
- Two deployment slots: `staging` and `testing`
- Slot-specific app settings and site configuration
- Health checks enabled on the main app and both slots

The example matches the contents of `linux_web_apps.tfvars` and uses the current module naming in this repository.

## Example contents

### Main app

- **Resource key**: `simple_app`
- **App name**: `simple-linux-web-app`
- **Runtime**: Node.js 22 LTS
- **Health check path**: `/health`
- **Health check eviction time**: 5 minutes
- **App settings**:
  - `WEBSITE_NODE_DEFAULT_VERSION = ~22`
  - `WEBSITE_RUN_FROM_PACKAGE = 1`

### Slot: `staging`

- **Slot name**: `staging`
- **Runtime**: Node.js 22 LTS
- **App settings**:
  - `WEBSITE_NODE_DEFAULT_VERSION = ~22`
  - `WEBSITE_RUN_FROM_PACKAGE = 1`
  - `ENVIRONMENT = staging`
  - `NODE_ENV = staging`
- **Site configuration**:
  - `minimum_tls_version = 1.2`
  - `ftps_state = FtpsOnly`
  - `http2_enabled = true`
  - `health_check_path = /health`
  - `health_check_eviction_time_in_min = 5`

### Slot: `testing`

- **Slot name**: `testing`
- **Runtime**: Node.js 22 LTS
- **App settings**:
  - `WEBSITE_NODE_DEFAULT_VERSION = ~22`
  - `WEBSITE_RUN_FROM_PACKAGE = 1`
  - `ENVIRONMENT = testing`
  - `NODE_ENV = testing`
  - `FEATURE_FLAGS = experimental`
- **Site configuration**:
  - `minimum_tls_version = 1.2`
  - `ftps_state = FtpsOnly`
  - `http2_enabled = true`
  - `health_check_path = /health`
  - `health_check_eviction_time_in_min = 5`

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- CAF Terraform provider configured
- Permissions to create the resource group, App Service plan, and Linux Web App resources

## Configuration files

This example follows the split-var-file layout used across the repository:

- `resource_groups.tfvars` - Resource group and shared location settings
- `service_plans.tfvars` - Linux App Service plan configuration
- `linux_web_apps.tfvars` - Linux Web App and slot configuration

## Deployment

From the `examples` directory, run Terraform with all three var files:

```bash
cd /path/to/terraform-azurerm-caf/examples

terraform init
terraform plan \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/linux_web_apps.tfvars

terraform apply \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/linux_web_apps.tfvars
```

## Usage

After deployment, you can:

1. Deploy new versions to `staging` or `testing` independently
2. Validate changes in a non-production slot before swapping
3. Swap a slot into the main app when you are ready to promote it
4. Monitor each slot separately using the `/health` endpoint

## Notes

- Deployment slots are supported by Standard, Premium, and Isolated App Service plans
- The example intentionally uses only the slots defined in `linux_web_apps.tfvars`
- The example does not include A/B testing or smoke-test slot names
- Slot-specific settings can be adjusted in `linux_web_apps.tfvars` without changing the README workflow

## Cleanup

```bash
terraform destroy \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/102-linux_web_app-slots/linux_web_apps.tfvars
```
