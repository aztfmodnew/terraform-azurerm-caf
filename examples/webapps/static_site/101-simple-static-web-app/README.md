# Simple Static Web App Example

This example demonstrates a basic Azure Static Web App deployment using the modern `azurerm_static_web_app` resource.

## What This Example Creates

- **Resource Group**: Container for the Static Web App
- **Static Web App**: Azure Static Web App with Standard SKU
- **Configuration**: Basic app settings and modern configurations

## Configuration Details

### Global Settings

```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  inherit_tags = true
  tags = {
    env = "demo"
    project = "static-web-app"
  }
}
```

### Static Web App Configuration

```hcl
static_sites = {
  s1 = {
    name               = "staticsite"
    resource_group_key = "rg1"
    region             = "region1"

    # SKU Configuration
    sku_tier = "Standard"  # Free or Standard
    sku_size = "Standard"  # Free or Standard

    # Feature toggles
    configuration_file_changes_enabled = true
    preview_environments_enabled       = true
    public_network_access_enabled     = true

    # Application settings
    app_settings = {
      "CUSTOM_SETTING" = "value"
      "ENVIRONMENT"    = "demo"
    }
  }
}
```

## Migration from Deprecated Resource

This example has been updated from the deprecated `azurerm_static_site` to the modern `azurerm_static_web_app` resource. Key improvements include:

- **Enhanced Configuration**: Better control over preview environments and configuration file changes
- **Modern API**: Uses the latest Azure Static Web Apps API version
- **Improved Security**: Support for public network access controls
- **Future-Proof**: Aligned with Azure's current Static Web Apps offering

## Deployment

```bash
# Navigate to the examples directory
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Initialize Terraform (if not already done)
terraform init

# Plan the deployment
terraform plan \
  -var-file=./webapps/static_site/101-simple-static-web-app/configuration.tfvars

# Apply the configuration
terraform apply \
  -var-file=./webapps/static_site/101-simple-static-web-app/configuration.tfvars
```

## Outputs

After deployment, you'll receive:

- **Static Web App ID**: For reference by other resources
- **Default Hostname**: The Azure-provided URL for your app
- **API Key**: For GitHub Actions integration and deployment

## Next Steps

1. **Deploy Your App**: Use GitHub Actions, Azure DevOps, or local deployment
2. **Configure CI/CD**: Set up automated deployments from your repository
3. **Add Custom Domains**: See the custom domain example for configuration
4. **Monitor Performance**: Use Azure Monitor and Application Insights

## Cost Considerations

- **Standard SKU**: Provides full features but incurs costs
- **Free SKU**: Available alternative with limited features
- **Data Transfer**: Consider bandwidth usage for your application

## Security Notes

- The example uses Standard SKU for production-ready features
- Public network access is enabled by default
- App settings can store non-sensitive configuration values
- For sensitive data, consider Azure Key Vault integration
