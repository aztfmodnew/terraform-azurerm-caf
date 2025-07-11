# Simple Linux Web App Example

This example demonstrates how to create a simple Linux Web App using the CAF terraform module.

## Resources Created

- Resource Group
- Service Plan (Linux, B1 SKU)
- Linux Web App with Node.js 20 LTS and health check configuration

## Features

- **Modern Runtime**: Uses Node.js 20-lts (latest LTS version)
- **Health Check**: Configured with `/health` endpoint and 5-minute eviction time
- **Security**: FTPS disabled, HTTP/2 enabled, always-on enabled
- **Deployment**: Configured for package deployment with `WEBSITE_RUN_FROM_PACKAGE`

## Usage

From the root directory of the CAF module (`/source/github/aztfmodnew/terraform-azurerm-caf/examples`):

```bash
terraform plan \
  -var-file=./webapps/linux_web_app/100-simple-linux-web-app/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/100-simple-linux-web-app/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/100-simple-linux-web-app/configuration.tfvars

terraform apply \
  -var-file=./webapps/linux_web_app/100-simple-linux-web-app/resource_groups.tfvars \
  -var-file=./webapps/linux_web_app/100-simple-linux-web-app/service_plans.tfvars \
  -var-file=./webapps/linux_web_app/100-simple-linux-web-app/configuration.tfvars
```

## Configuration

The example shows:

- **Runtime Configuration**: Node.js 20-lts (latest LTS version)
- **Health Check**: `/health` endpoint with 5-minute eviction time
- **App Settings**: Updated for Node.js 20 and health check tuning
- **Security**: FTPS disabled, HTTP/2 enabled, always-on enabled
- **Resource Tagging**: Environment and purpose tags

### Key Configuration Details

```hcl
application_stack = {
  node_version = "20-lts"  # Latest LTS version
}

health_check_path                 = "/health"
health_check_eviction_time_in_min = 5

app_settings = {
  "WEBSITE_NODE_DEFAULT_VERSION" = "~20"
  "WEBSITE_RUN_FROM_PACKAGE"     = "1"
}
```

**Note**: When using `health_check_eviction_time_in_min`, Azure automatically manages the `WEBSITE_HEALTHCHECK_MAXPINGFAILURES` setting, so it should not be set manually in `app_settings`.

## Health Check Endpoint

The web app is configured with a health check endpoint at `/health`. For this example to work properly, your application should implement a health check endpoint that returns:

- **HTTP 200** status code when the application is healthy
- **HTTP 5xx** status code when the application is unhealthy

Example Node.js health check implementation:
```javascript
app.get('/health', (req, res) => {
  // Add your health check logic here
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});
```

## Migration from azurerm_app_service

This module replaces the deprecated `azurerm_app_service` resource. Key differences:

1. **Resource Type**: Uses `azurerm_linux_web_app` instead of `azurerm_app_service`
2. **OS Specific**: Dedicated to Linux workloads (use `windows_web_app` for Windows)
3. **Application Stack**: Structured configuration for runtime versions
4. **Enhanced Security**: Better defaults for security settings
5. **Health Checks**: Built-in health check configuration

## Validation

After deployment, you can verify:

1. **Web App Status**: Check the web app is running in the Azure portal
2. **Health Check**: The health check endpoint should be accessible
3. **Runtime Version**: Confirm Node.js 20-lts is being used
4. **No Deprecated Warnings**: The web app should not show runtime deprecation warnings

## Next Steps

For more advanced scenarios, see other examples in this directory that demonstrate:

- Custom domains and SSL certificates
- Authentication and authorization
- Virtual network integration
- Application insights integration
