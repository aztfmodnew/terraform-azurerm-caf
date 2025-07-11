# Static Web App Examples

This directory contains examples for deploying Azure Static Web Apps using the CAF Terraform framework. All examples have been updated to use the modern `azurerm_static_web_app` resource.

## Examples Overview

### 101-simple-static-web-app

Demonstrates a basic Static Web App deployment with:

- **Standard SKU**: Required for production workloads
- **Configuration Management**: Control over configuration file changes
- **Preview Environments**: Staging environment support
- **Public Network Access**: Internet-accessible endpoint
- **App Settings**: Custom application configuration
- **Tags**: Resource organization and cost tracking

### 102-static-web-app-custom-domain

Demonstrates a Static Web App with custom domain configuration featuring:

- **Multiple Domain Types**: Root domain, subdomains, and www subdomain
- **Two Validation Methods**:
  - `dns-txt-token`: Required for apex/root domains
  - `cname-delegation`: For subdomains
- **DNS Configuration Examples**: Complete setup instructions
- **Standard SKU**: Required for custom domain functionality

## Migration Notes

### ✅ Updated Resources

- **FROM**: `azurerm_static_site` (deprecated)
- **TO**: `azurerm_static_web_app` (modern)

- **FROM**: `azurerm_static_site_custom_domain` (deprecated)
- **TO**: `azurerm_static_web_app_custom_domain` (modern)

### Key Changes

1. **Resource Names**: Updated to use modern Azure provider resources
2. **SKU Configuration**: Simplified to `sku_tier` and `sku_size`
3. **Custom Domains**: Now separate resources linked via `static_web_app_id`
4. **Enhanced Configuration**: Added support for preview environments, configuration file changes, and public network access controls

## Usage

### Simple Example

Navigate to the examples directory and run:

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform plan \
  -var-file=./webapps/static_site/101-simple-static-web-app/configuration.tfvars

terraform apply \
  -var-file=./webapps/static_site/101-simple-static-web-app/configuration.tfvars
```

### Custom Domain Example

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform plan \
  -var-file=./webapps/static_site/102-static-web-app-custom-domain/configuration.tfvars

terraform apply \
  -var-file=./webapps/static_site/102-static-web-app-custom-domain/configuration.tfvars
```

## DNS Configuration for Custom Domains

After deployment, you'll need to configure DNS records:

### For Root Domain (dns-txt-token validation)

1. **TXT Record**: Create `_dnsauth.yourdomain.com` with the validation token from Terraform output
2. **A/ALIAS Record**: Point `yourdomain.com` to the Static Web App's default hostname

### For Subdomains (cname-delegation validation)

1. **CNAME Record**: Point `subdomain.yourdomain.com` to the Static Web App's default hostname

## Important Notes

- **SKU Requirements**: Custom domains require Standard SKU
- **Validation Process**: TXT validation is asynchronous; Terraform doesn't wait for completion
- **DNS Propagation**: Allow time for DNS changes to propagate globally
- **Apex Domains**: Must use `dns-txt-token` validation
- **CNAME Limitations**: Cannot be used for root/apex domains

## Outputs

Both examples expose:

- `static_web_app_id`: Resource ID for reference by other resources
- `default_host_name`: Default hostname for DNS configuration
- `api_key`: For GitHub Actions and other integrations
- `validation_tokens`: For custom domain DNS configuration (when applicable)

## Cost Considerations

- **Free SKU**: Limited features, no custom domains
- **Standard SKU**: Full features including custom domains, higher costs
- **Data Transfer**: Consider bandwidth usage for production workloads
- **Build Minutes**: GitHub Actions integration may incur additional costs

## Security Best Practices

1. Use Standard SKU for production workloads
2. Configure appropriate app settings for environment variables
3. Use managed identities where possible
4. Implement proper DNS security for custom domains
5. Monitor access patterns and implement rate limiting if needed
