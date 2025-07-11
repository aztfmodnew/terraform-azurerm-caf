# Linux Web App Examples

This directory contains comprehensive examples for deploying Linux Web Apps using the Azure CAF (Cloud Adoption Framework) Terraform module. These examples demonstrate various scenarios and configurations for Linux Web Apps.

## Examples Overview

| Example                                                           | Description              | Features                                                  |
| ----------------------------------------------------------------- | ------------------------ | --------------------------------------------------------- |
| [100-simple-linux-web-app](./100-simple-linux-web-app/)           | Basic Linux Web App      | Simple deployment with minimal configuration              |
| [101-linux_web_app-simple](./101-linux_web_app-simple/)           | Simple Linux Web App     | Basic deployment with Python runtime                      |
| [102-linux_web_app-slots](./102-linux_web_app-slots/)             | Linux Web App with Slots | Deployment slots for staging/production                   |
| [103-linux_web_app-extend](./103-linux_web_app-extend/)           | Extended Configuration   | IP restrictions, CORS, storage mounts, connection strings |
| [104-linux_web_app-appinsight](./104-linux_web_app-appinsight/)   | Application Insights     | Monitoring and telemetry integration                      |
| [105-linux_web_app-backup](./105-linux_web_app-backup/)           | Backup Configuration     | Automated backup with storage accounts                    |
| [106-linux_web_app-diagnostics](./106-linux_web_app-diagnostics/) | Diagnostics Logging      | Event Hub diagnostics integration                         |
| [107-linux_web_app-private](./107-linux_web_app-private/)         | Private Networking       | VNet integration and private endpoints                    |
| [108-linux_web_app-autoscale](./108-linux_web_app-autoscale/)     | Auto-scaling             | Monitor-based auto-scaling configuration                  |
| [108-linux_web_app-storage](./108-linux_web_app-storage/)         | Storage Integration      | Azure Files and Blob storage mounts                       |
| [109-linux_web_app-appgw](./109-linux_web_app-appgw/)             | Application Gateway      | Load balancing with Application Gateway                   |
| [110-linux_web_app-auth](./110-linux_web_app-auth/)               | Authentication           | Azure AD authentication integration                       |

## Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.6.0
- CAF Terraform provider configured
- Appropriate Azure permissions for resource creation

## Common Configuration Pattern

All examples follow the CAF pattern of separating resources into logical tfvars files:

- `resource_groups.tfvars` - Resource groups and global settings
- `service_plans.tfvars` - App Service Plans
- `linux_web_apps.tfvars` - Linux Web App configuration
- Additional service-specific tfvars files as needed

## General Deployment Steps

1. Navigate to the examples directory:

   ```bash
   cd /path/to/terraform-azurerm-caf/examples
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Plan deployment with specific example tfvars:

   ```bash
   terraform plan -var-file=./webapps/linux_web_app/[example-name]/[config-files].tfvars
   ```

4. Apply deployment:

   ```bash
   terraform apply -var-file=./webapps/linux_web_app/[example-name]/[config-files].tfvars
   ```

5. Clean up resources:
   ```bash
   terraform destroy -var-file=./webapps/linux_web_app/[example-name]/[config-files].tfvars
   ```

## Key Features Demonstrated

### Runtime Support

- Python 3.8 application stack
- Node.js runtime configurations
- Custom application commands

### Security Features

- System-assigned managed identities
- IP restrictions and access control
- Private endpoints and VNet integration
- Azure AD authentication

### Monitoring & Diagnostics

- Application Insights integration
- Diagnostic logging to Event Hub
- Custom metrics and monitoring

### Scalability

- Auto-scaling based on CPU metrics
- Load balancing with Application Gateway
- Deployment slots for zero-downtime deployments

### Storage Integration

- Azure Files and Blob storage mounts
- Connection strings for databases
- Backup configurations

## Module Features

These examples showcase the full capabilities of the CAF Linux Web App module:

- ✅ **CAF Compliance**: Follows Azure Cloud Adoption Framework standards
- ✅ **Resource Naming**: Uses azurecaf provider for consistent naming
- ✅ **Dependency Management**: Proper resource dependency resolution
- ✅ **Feature Parity**: Equivalent functionality to Windows Web App module
- ✅ **Private Endpoints**: Secure networking integration
- ✅ **Storage Support**: Azure Files and Blob storage mounting
- ✅ **Monitoring**: Application Insights and diagnostics integration
- ✅ **Authentication**: Azure AD integration support
- ✅ **Slots Support**: Deployment slots for staging scenarios

## Migration from Windows Web Apps

These Linux Web App examples provide equivalent functionality to the Windows Web App examples, with appropriate Linux-specific configurations:

- Application stack uses Python instead of .NET Framework
- Default documents use `index.html` instead of `main.aspx`
- Storage mounts use Linux-appropriate mount paths
- All other features maintain functional parity

## Support and Contributions

For issues or contributions related to these examples:

1. Check the individual example README files for specific guidance
2. Review the module documentation in `/modules/webapps/linux_web_app/`
3. Ensure all prerequisites are met before deployment
4. Follow the CAF standards for any custom modifications
