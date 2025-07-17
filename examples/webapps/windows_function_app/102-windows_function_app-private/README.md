# Windows Function App with Private Endpoint

This example demonstrates how to deploy a Windows-based Azure Function App with private endpoint connectivity for enhanced security.

## Architecture Overview

This deployment creates:

- **Windows Function App** with VNet integration and private endpoint
- **Premium Service Plan** (P1v3) required for VNet integration
- **Storage Account** with private endpoints for blob and file services
- **Virtual Network** with dedicated subnets for functions and private endpoints
- **Private DNS Zones** for proper name resolution
- **Network Security Groups** for traffic control
- **Managed Identity** for secure access to storage

## Security Features

### Network Isolation

- ✅ **Private Endpoint**: Function app accessible only through private IP
- ✅ **VNet Integration**: Outbound traffic routed through VNet
- ✅ **Storage Private Endpoints**: Storage accessible only through private network
- ✅ **Public Access Disabled**: Both function app and storage have public access disabled
- ✅ **Network Security Groups**: Traffic filtering at subnet level

### Access Control

- ✅ **Managed Identity**: Secure authentication to storage without connection strings
- ✅ **IP Restrictions**: Function app accessible only from VNet
- ✅ **HTTPS Only**: All traffic encrypted in transit
- ✅ **Minimum TLS 1.2**: Modern encryption standards

### Compliance

- ✅ **Zero Trust Architecture**: All resources isolated by default
- ✅ **Private DNS Resolution**: Proper name resolution within VNet
- ✅ **Audit Trail**: All access through private endpoints logged

## Prerequisites

- Azure subscription with appropriate permissions
- Understanding of Azure networking concepts
- Premium service plan pricing awareness

## Deployment

From the examples directory, run:

```bash
cd /home/$USER/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Plan the deployment
terraform plan \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/configuration.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/nsg.tfvars

# Apply the deployment
terraform apply \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/configuration.tfvars \
  -var-file=./webapps/windows_function_app/102-windows_function_app-private/nsg.tfvars
```

## Configuration Files

| File                   | Purpose                               |
| ---------------------- | ------------------------------------- |
| `configuration.tfvars` | Main configuration with all resources |
| `nsg.tfvars`           | Network Security Groups definitions   |

## Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       spoke-vnet (10.1.0.0/22)                 │
├─────────────────────────────────────────────────────────────────┤
│ ┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────── │
│ │   snet-functions    │ │ snet-privateendpoints│ │  snet-bastion  │
│ │   (10.1.0.0/26)     │ │   (10.1.1.0/26)     │ │ (10.1.2.0/26)  │
│ │                     │ │                     │ │                │
│ │ ┌─────────────────┐ │ │ ┌─────────────────┐ │ │                │
│ │ │ Windows Function│ │ │ │ Storage PE      │ │ │                │
│ │ │ App (VNet       │ │ │ │ - Blob          │ │ │                │
│ │ │ Integration)    │ │ │ │ - File          │ │ │                │
│ │ └─────────────────┘ │ │ │                 │ │ │                │
│ │                     │ │ │ ┌─────────────┐ │ │ │                │
│ │                     │ │ │ │Function PE  │ │ │ │                │
│ │                     │ │ │ │- sites      │ │ │ │                │
│ │                     │ │ │ └─────────────┘ │ │ │                │
│ └─────────────────────┘ │ └─────────────────┘ │ └─────────────── │
└─────────────────────────────────────────────────────────────────┘
```

## Post-Deployment

### Testing Connectivity

1. **Private Endpoint Resolution**:

   ```bash
   # From within the VNet, resolve the private endpoint
   nslookup winfunapp-private.azurewebsites.net
   # Should return a 10.1.1.x IP address
   ```

2. **Function App Access**:

   ```bash
   # From within the VNet
   curl https://winfunapp-private.azurewebsites.net/api/healthcheck
   ```

3. **Storage Access**:
   ```bash
   # Verify storage private endpoint
   nslookup winfunappprivsa.blob.core.windows.net
   # Should return a 10.1.1.x IP address
   ```

### Monitoring

- Enable Application Insights for function monitoring
- Set up Azure Monitor for network traffic analysis
- Configure diagnostic settings for private endpoint logs

## Troubleshooting

### Common Issues

1. **DNS Resolution**: Ensure private DNS zones are properly linked to VNet
2. **Storage Access**: Verify managed identity has appropriate permissions
3. **Network Connectivity**: Check NSG rules and route tables
4. **Function App Startup**: Review app settings and storage configuration

### Validation Steps

1. Verify all private endpoints show "Approved" status
2. Confirm DNS resolution returns private IP addresses
3. Test function app accessibility from within VNet
4. Validate storage account accessibility via private endpoint

## Cost Considerations

- **Premium Service Plan**: Higher cost but required for VNet integration
- **Private Endpoints**: Additional cost per endpoint
- **Storage Account**: Standard pricing with private endpoint costs
- **VNet**: No additional cost for basic VNet

## Security Benefits

- ✅ **Zero Public Exposure**: No internet-facing endpoints
- ✅ **Data Sovereignty**: All traffic stays within your network
- ✅ **Compliance Ready**: Meets strict security requirements
- ✅ **Audit Trail**: All network access logged and traceable
- ✅ **Identity-Based Access**: No connection strings or keys exposed

## Related Examples

- [Simple Windows Function App](../101-windows_function_app-simple/) - Basic deployment without private endpoints
- [Linux Function App Private](../../linux_function_app/101-linux_function_app-private/) - Linux equivalent with private networking
