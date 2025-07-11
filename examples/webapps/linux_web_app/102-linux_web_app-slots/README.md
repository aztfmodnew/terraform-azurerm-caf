# Linux Web App with Deployment Slots

This example demonstrates how to create a Linux Web App with deployment slots for staging and A/B testing scenarios.

## Overview

This example creates:
- A Linux Web App with Node.js 20 LTS runtime
- Two deployment slots: `smoke-test` and `ab-testing`
- Different app settings for each slot to demonstrate environment-specific configurations
- Health check configuration for all slots
- Modern security settings (TLS 1.2, FTPS only, HTTP/2)

## Deployment Slots

### Production Slot (Main)
- **Environment**: production
- **Node.js Version**: 20 LTS
- **Health Check**: `/health` endpoint with 5-minute eviction time

### Smoke Test Slot
- **Environment**: staging
- **Purpose**: Pre-production testing and validation
- **Configuration**: Similar to production but with staging-specific settings

### A/B Testing Slot
- **Environment**: testing
- **Purpose**: A/B testing and feature flag experiments
- **Configuration**: Includes experimental feature flags

## Key Features

1. **Multiple Deployment Slots**: Enables blue-green deployments and testing
2. **Environment-Specific Settings**: Different app settings per slot
3. **Health Monitoring**: Health checks configured for all slots
4. **Modern Runtime**: Node.js 20 LTS (latest supported version)
5. **Security**: TLS 1.2, FTPS only, and HTTP/2 enabled

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.6.0
- Azure CLI or service principal authentication

## Deployment

```bash
# Navigate to examples directory
cd /path/to/terraform-azurerm-caf/examples

# Initialize and deploy
terraform init
terraform plan -var-file=./webapps/linux_web_app/102-linux_web_app-slots/configuration.tfvars
terraform apply -var-file=./webapps/linux_web_app/102-linux_web_app-slots/configuration.tfvars
```

## Usage

After deployment, you can:

1. **Deploy to slots**: Use Azure DevOps, GitHub Actions, or manual deployment to deploy different versions to each slot
2. **Test in isolation**: Each slot has its own URL and configuration
3. **Swap slots**: Use slot swapping to promote staging to production with zero downtime
4. **Monitor health**: Each slot reports health status independently

## Expected Outputs

- **Main Web App**: `https://linux-webapp-slots-{random}.azurewebsites.net`
- **Smoke Test Slot**: `https://linux-webapp-slots-{random}-smoke-test.azurewebsites.net`
- **A/B Testing Slot**: `https://linux-webapp-slots-{random}-ab-testing.azurewebsites.net`

## Health Check Endpoint

Your application should implement a `/health` endpoint that returns:
- **Status Code**: 200 (OK)
- **Response**: JSON with application health status

Example implementation:
```javascript
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});
```

## Cleanup

```bash
terraform destroy -var-file=./webapps/linux_web_app/102-linux_web_app-slots/configuration.tfvars
```

## Notes

- Deployment slots are only available in Standard, Premium, and Isolated service plans
- Each slot has its own configuration and can be deployed independently
- Slot swapping allows zero-downtime deployments
- Health checks help ensure application availability across all slots
