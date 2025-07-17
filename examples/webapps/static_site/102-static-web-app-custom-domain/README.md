# Static Web App with Custom Domain Example

This example demonstrates an Azure Static Web App deployment with custom domain configuration using the modern `azurerm_static_web_app_custom_domain` resource.

## What This Example Creates

- **Resource Group**: Container for the Static Web App
- **Static Web App**: Azure Static Web App with Standard SKU
- **Custom Domains**: Multiple domain configurations with different validation methods

## Custom Domain Types Demonstrated

### 1. Root Domain (dns-txt-token validation)

- **Domain**: `mystaticsite.com`
- **Validation**: TXT record
- **Use Case**: Apex domain configuration

### 2. Subdomain (cname-delegation validation)

- **Domain**: `subdomain.mystaticsite.com`
- **Validation**: CNAME record
- **Use Case**: Service-specific subdomain

### 3. WWW Subdomain (cname-delegation validation)

- **Domain**: `www.mystaticsite.com`
- **Validation**: CNAME record
- **Use Case**: Traditional www prefix

## Configuration Details

### Static Web App with Custom Domains

```hcl
static_sites = {
  s1 = {
    name               = "staticsite"
    resource_group_key = "rg1"
    region             = "region1"

    # Standard SKU required for custom domains
    sku_tier = "Standard"
    sku_size = "Standard"

    custom_domains = {
      txt_domain = {
        domain_name     = "mystaticsite.com"
        validation_type = "dns-txt-token"
      }
      cname_subdomain = {
        domain_name     = "subdomain.mystaticsite.com"
        validation_type = "cname-delegation"
      }
      www_subdomain = {
        domain_name     = "www.mystaticsite.com"
        validation_type = "cname-delegation"
      }
    }
  }
}
```

## DNS Configuration Required

### After Deployment

Once Terraform creates the resources, you'll need to configure DNS records with your domain provider:

#### For Root Domain (`mystaticsite.com`)

1. **TXT Record**:
   - **Name**: `_dnsauth.mystaticsite.com` or `_dnsauth` (depending on your DNS provider)
   - **Value**: Use the `validation_token` from Terraform output
   - **TTL**: 300 seconds (or your provider's minimum)

2. **A Record or ALIAS**:
   - **Name**: `@` or `mystaticsite.com`
   - **Value**: The `default_host_name` from Terraform output
   - **TTL**: 3600 seconds

#### For Subdomains (`subdomain.mystaticsite.com`, `www.mystaticsite.com`)

1. **CNAME Record**:
   - **Name**: `subdomain` (or `www`)
   - **Value**: The `default_host_name` from Terraform output
   - **TTL**: 3600 seconds

## Validation Process

### TXT Token Validation (Root Domain)

- **Process**: Asynchronous
- **Terraform Behavior**: Does not wait for completion
- **Verification**: Check Azure portal for validation status
- **Timeline**: Usually completes within 5-10 minutes after DNS propagation

### CNAME Delegation (Subdomains)

- **Process**: Automatic
- **Terraform Behavior**: Waits for validation
- **Verification**: CNAME resolution to static web app hostname
- **Timeline**: Usually completes within 2-5 minutes

## Deployment

```bash
# Navigate to the examples directory
cd /home/$USER/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Plan the deployment
terraform plan \
  -var-file=./webapps/static_site/102-static-web-app-custom-domain/configuration.tfvars

# Apply the configuration
terraform apply \
  -var-file=./webapps/static_site/102-static-web-app-custom-domain/configuration.tfvars

# Note the outputs for DNS configuration
terraform output
```

## Migration from Deprecated Resource

This example has been updated from the deprecated `azurerm_static_site_custom_domain` to the modern `azurerm_static_web_app_custom_domain` resource. Key improvements include:

- **Separate Resource Management**: Custom domains are now independent resources
- **Better Lifecycle Management**: Each domain can be managed independently
- **Enhanced Validation**: Improved validation token handling
- **Modern API**: Uses the latest Azure Static Web Apps API version

## Troubleshooting

### Domain Validation Issues

1. **TXT Record Not Found**:
   - Verify TXT record name format with your DNS provider
   - Check DNS propagation using `nslookup` or online DNS tools
   - Wait for full DNS propagation (up to 48 hours globally)

2. **CNAME Validation Fails**:
   - Ensure CNAME points to the exact default hostname
   - Remove any trailing dots from the CNAME value
   - Verify no conflicting A records exist

3. **Azure Portal Status**:
   - Check the Static Web App custom domains section
   - Look for validation status and error messages
   - Re-trigger validation if needed

### DNS Propagation Verification

```bash
# Check TXT record
nslookup -type=TXT _dnsauth.mystaticsite.com

# Check CNAME record
nslookup subdomain.mystaticsite.com

# Check A record (for root domain)
nslookup mystaticsite.com
```

## Cost Considerations

- **Standard SKU Required**: Custom domains require Standard tier
- **DNS Provider Costs**: Additional costs from your domain registrar
- **SSL Certificates**: Azure provides free SSL certificates for custom domains
- **Data Transfer**: Consider bandwidth usage across all domains

## Security Best Practices

1. **SSL/TLS**: Azure automatically provides SSL certificates for custom domains
2. **DNS Security**: Use DNSSEC if supported by your DNS provider
3. **Domain Validation**: Monitor validation status to prevent domain hijacking
4. **Access Control**: Consider restricting public network access if needed
5. **Monitoring**: Set up alerts for domain validation failures

## Next Steps

1. **Configure DNS**: Set up the required DNS records
2. **Verify Domains**: Check validation status in Azure portal
3. **Test Access**: Verify all domains resolve correctly
4. **Set Up Redirects**: Configure redirects between domains if needed
5. **Monitor Performance**: Use Azure Monitor for domain-specific metrics
