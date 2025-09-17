# Azure Bot with WAF and Private Endpoint Example

This example demonstrates how to deploy an Azure Bot Service protected by a Web Application Firewall (WAF) and accessed through private endpoints for enhanced security.

## Architecture Overview

```
Internet → Application Gateway (with WAF) → Azure Bot Service (Private Endpoint) → Virtual Network
```

### Components Deployed

1. **Azure Bot Service** - The main chatbot service
2. **Application Gateway with WAF** - Provides web application firewall protection and load balancing
3. **Private Endpoint** - Ensures secure, private connectivity to the bot service
4. **Virtual Network** - Network isolation and segmentation
5. **Private DNS Zone** - For private endpoint name resolution
6. **Public IP** - For Application Gateway external access
7. **Network Security Groups** - Additional network security controls

## Security Features

### Web Application Firewall (WAF)
- **OWASP 3.1 Rules** - Protection against common web vulnerabilities
- **Custom Rules** - IP allowlisting and custom security policies
- **DDoS Protection** - Built-in protection against distributed denial-of-service attacks
- **Bot Protection** - Advanced bot detection and mitigation

### Private Endpoints
- **Network Isolation** - Bot service is not accessible from the public internet
- **Private DNS Resolution** - Internal name resolution through private DNS zones
- **Secure Communication** - All traffic flows through the virtual network

### Network Security
- **Network Security Groups** - Layer 4 firewall rules
- **Subnet Segmentation** - Separate subnets for different components
- **Private Link** - Secure connection to Azure services

## Configuration Files

- `configuration.tfvars` - Main configuration with all resources
- `waf.tfvars` - WAF policy configuration
- `application_gateways.tfvars` - Application Gateway configuration
- `networking.tfvars` - Virtual network and subnet configuration

## Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Bot Framework Registration** - Microsoft App ID and secret
3. **Domain Name** (optional) - For custom domain configuration
4. **SSL Certificate** (optional) - For HTTPS termination

## Deployment Steps

1. **Configure Variables**
   ```bash
   # Update the Microsoft App ID in configuration.tfvars
   microsoft_app_id = "your-app-id-here"
   microsoft_app_tenant_id = "your-tenant-id-here"
   ```

2. **Deploy Infrastructure**
   ```bash
   cd /examples
   terraform init
   terraform plan -var-file="bot/104-azure-bot-waf-private-endpoint/configuration.tfvars"
   terraform apply -var-file="bot/104-azure-bot-waf-private-endpoint/configuration.tfvars"
   ```

3. **Configure Bot Endpoint**
   - Update your bot application's messaging endpoint to point to the Application Gateway's public IP
   - Endpoint format: `https://<app-gateway-ip>/api/messages`

4. **Test Connectivity**
   - Verify the bot is accessible through the Application Gateway
   - Test WAF rules by attempting blocked requests
   - Confirm private endpoint connectivity

## Security Configuration

### WAF Policy
The WAF policy includes:
- **Managed Rules**: OWASP Core Rule Set 3.1
- **Custom Rules**: IP allowlisting, geo-blocking
- **Exclusions**: For legitimate bot framework traffic
- **Anomaly Scoring**: Advanced threat detection

### Private Endpoint
- **Subresource**: `bot` - Direct connection to bot service
- **Network Policies**: Enabled for fine-grained control
- **DNS Integration**: Automatic private DNS zone creation

## Monitoring and Logging

- **Application Gateway Logs** - Access logs and performance metrics
- **WAF Logs** - Security events and blocked requests
- **Bot Service Logs** - Bot conversations and errors
- **Network Security Group Logs** - Network traffic analysis

## Cost Considerations

- **Application Gateway**: Standard_v2 SKU with autoscaling
- **Bot Service**: S1 SKU (required for private endpoints)
- **Private Endpoint**: Per-endpoint hourly charges
- **Data Transfer**: Inbound traffic is free, outbound charges apply

## Limitations

- Bot Service private endpoints require S1 SKU or higher
- Application Gateway v2 is required for WAF v2 features
- Private endpoints are region-specific

## Troubleshooting

### Common Issues
1. **Bot Not Responding**
   - Check Application Gateway backend health
   - Verify bot endpoint configuration
   - Review WAF logs for blocked requests

2. **DNS Resolution Issues**
   - Verify private DNS zone configuration
   - Check virtual network links
   - Validate DNS settings on client machines

3. **SSL/TLS Issues**
   - Verify certificate configuration on Application Gateway
   - Check cipher suites and TLS versions
   - Review SSL policy settings

## Advanced Configurations

### Multi-Region Deployment
- Deploy Application Gateways in multiple regions
- Use Traffic Manager for global load balancing
- Configure geo-redundant bot services

### High Availability
- Configure Application Gateway with multiple instances
- Use availability zones for fault tolerance
- Implement backup and disaster recovery

### Integration with Other Services
- **Azure Active Directory** - For authentication
- **Azure Key Vault** - For certificate and secret management
- **Azure Monitor** - For comprehensive monitoring
- **Azure Sentinel** - For security information and event management (SIEM)

## Next Steps

1. **Enable Additional Security Features**
   - Configure Azure DDoS Protection Standard
   - Implement Azure Front Door for global distribution
   - Add Azure Security Center recommendations

2. **Enhance Monitoring**
   - Set up Azure Monitor alerts
   - Configure Log Analytics workspace
   - Implement custom dashboards

3. **Optimize Performance**
   - Tune Application Gateway settings
   - Optimize WAF rules for performance
   - Configure caching strategies

## References

- [Azure Bot Service Documentation](https://docs.microsoft.com/en-us/azure/bot-service/)
- [Application Gateway WAF Documentation](https://docs.microsoft.com/en-us/azure/web-application-firewall/)
- [Private Endpoints Documentation](https://docs.microsoft.com/en-us/azure/private-link/)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/)
