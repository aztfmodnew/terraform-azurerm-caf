# Linux Web App - Application Insights Integration Example

This example demonstrates how to deploy a Linux Web App with Application Insights integration for monitoring and telemetry.

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- CAF Terraform provider configured

## Resources Created

- Resource Group
- Application Insights instance
- App Service Plan (Linux, P1v2)
- Linux Web App with Application Insights integration

## Configuration Files

- `resource_groups.tfvars` - Resource group configuration
- `application_insights.tfvars` - Application Insights configuration
- `service_plans.tfvars` - App Service Plan configuration
- `linux_web_apps.tfvars` - Linux Web App configuration

## Deployment

Navigate to the examples directory and run:

```bash
cd /path/to/terraform-azurerm-caf/examples

terraform init
terraform plan \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/application_insights.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/linux_web_apps.tfvars

terraform apply \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/application_insights.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/linux_web_apps.tfvars
```

## Cleanup

```bash
terraform destroy \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/application_insights.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/104-linux_web_app-appinsight/linux_web_apps.tfvars
```

## Features Demonstrated

- **Application Insights**: Integrated monitoring and telemetry
- **Python Runtime**: Python 3.8 application stack
- **Automatic Instrumentation**: Built-in performance monitoring
