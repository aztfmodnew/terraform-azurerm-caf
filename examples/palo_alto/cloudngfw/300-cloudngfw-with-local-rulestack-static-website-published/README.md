# Palo Alto Cloud NGFW with Static Website Example

This example demonstrates how to deploy a Palo Alto Cloud NGFW to protect a static website hosted on Azure Storage with static website hosting enabled.

## Architecture Overview

```
Internet → Palo Alto Cloud NGFW → Azure Storage Static Website
                ↓
        Security Policies & Logging
```

This setup provides enterprise-grade security for static web content using:
- **Palo Alto Cloud NGFW** with local rulestack for security policies
- **Azure Storage Account** with static website hosting
- **Network segmentation** with dedicated subnets
- **Service endpoints** for secure backend access

## Components

### 1. Network Infrastructure
- **Virtual Network**: Segmented subnets for different security zones
- **Subnets**:
  - Management subnet (10.100.1.0/24) - NGFW management
  - Trust subnet (10.100.2.0/24) - Internal trusted network
  - Untrust subnet (10.100.3.0/24) - Internet-facing traffic
  - Backend subnet (10.100.4.0/24) - Storage access with service endpoints
- **Public IPs**: Management and dataplane access
- **Network Security Groups**: Layer 4 security controls

### 2. Palo Alto Cloud NGFW
- **Management Mode**: Local Rulestack
- **Attachment Type**: VNet
- **Security Features**: 
  - Traffic inspection and logging
  - Threat prevention capabilities
  - Application-level filtering
  - NAT and egress capabilities

### 3. Azure Storage Account
- **Type**: StorageV2 with static website hosting enabled
- **Content**: Professional static website demonstrating security features
- **Access Control**: Service endpoints for secure backend access
- **CORS**: Configured for web browsers

### 4. Static Website Content
- **index.html**: Main landing page showcasing security features
- **404.html**: Custom error page with security messaging
- **styles.css**: Enhanced styling and responsive design
- **robots.txt**: SEO configuration

## File Structure

```
300-cloudngfw-with-local-rulestack-static-website-published/
├── configuration.tfvars           # Main infrastructure configuration
├── storage_blobs.tfvars          # Storage blob configuration for website content
├── website_content/              # Static website files
│   ├── index.html               # Main page
│   ├── 404.html                 # Error page
│   ├── styles.css               # CSS styles
│   └── robots.txt               # SEO configuration
└── README.md                    # This documentation
```

## Configuration Files

### Primary Configuration (`configuration.tfvars`)
- Resource groups for NGFW and storage
- Virtual network with segmented subnets
- Public IP addresses for NGFW
- Network security group rules
- Storage account with static website hosting
- Palo Alto Cloud NGFW with local rulestack

### Storage Blobs (`storage_blobs.tfvars`)
- Configuration for uploading website content to storage
- Maps local files to storage blob locations
- Proper content types for web assets

## Deployment Steps

### Prerequisites

⚠️ **IMPORTANT**: Before running this example, you must register the PaloAlto resource provider in your Azure subscription:

```bash
# Register the PaloAlto resource provider
az provider register --namespace PaloAltoNetworks.Cloudngfw

# Check registration status (this may take several minutes)
az provider show --namespace PaloAltoNetworks.Cloudngfw --query "registrationState"
```

**Wait for registration to complete** - the status should show "Registered" before proceeding.

**Additional Prerequisites:**
- Azure subscription with Palo Alto Cloud NGFW licensing
- Terraform >= 1.6.0
- Azure CLI authenticated
- Contributor or Owner permissions on the subscription

### Deploy Infrastructure

1. **Navigate to examples directory**
   ```bash
   cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples
   ```

2. **Plan the deployment**
   ```bash
   terraform_with_var_files --dir /palo_alto/cloudngfw/300-cloudngfw-with-local-rulestack-static-website-published/ --action plan --auto auto --workspace staticweb
   ```

3. **Apply the configuration**
   ```bash
   terraform_with_var_files --dir /palo_alto/cloudngfw/300-cloudngfw-with-local-rulestack-static-website-published/ --action apply --auto auto --workspace staticweb
   ```

4. **Upload website content**
   The static website content will be automatically uploaded to the storage account during deployment.

## Security Features

### Network Security
- **Segmented subnets**: Isolation between management, trust, untrust, and backend
- **Service endpoints**: Direct secure access from backend subnet to storage
- **NSG rules**: Allow HTTP/HTTPS from trust subnet to backend
- **Public IP protection**: Only NGFW dataplane exposed to internet

### NGFW Security
- **Local rulestack**: Custom security policies for the static website
- **Traffic inspection**: All traffic flows through NGFW for analysis
- **Threat prevention**: Built-in security capabilities
- **Logging**: Comprehensive traffic and security event logging

### Application Security
- **CORS configuration**: Proper cross-origin resource sharing
- **Content type validation**: Appropriate MIME types for web content
- **Error handling**: Custom 404 page maintains security messaging

## Accessing the Website

After successful deployment:

1. **Get NGFW public IP**: From Terraform outputs or Azure portal
2. **Access website**: `http://<ngfw-public-ip>`
3. **View security features**: Website content explains the security architecture

## Monitoring and Logging

### NGFW Monitoring
- Traffic flow logs through Palo Alto management interface
- Security events and threat detection alerts
- Performance metrics and utilization data

### Azure Monitoring
- Storage account access logs and metrics
- Network security group flow logs
- Application insights (if configured)

## Customization Options

### Security Policies
Edit the NGFW local rulestack configuration to:
- Add custom security rules
- Configure threat prevention profiles
- Set up URL filtering policies
- Enable SSL decryption (requires certificates)

### Website Content
Modify files in `website_content/` directory to:
- Update design and branding
- Add additional pages and content
- Include interactive features
- Customize error pages

### Network Configuration
Adjust network settings for:
- Different subnet CIDR ranges
- Additional security zones
- Custom routing requirements
- Integration with existing networks

## Troubleshooting

### Common Issues

1. **Website not accessible**
   - Verify NGFW public IP is reachable
   - Check NSG rules allow traffic
   - Confirm storage account static website is enabled

2. **Content not loading**
   - Verify blob upload completed successfully
   - Check content types are correctly set
   - Ensure CORS rules allow browser access

3. **Security policy issues**
   - Review NGFW logs for blocked traffic
   - Verify local rulestack configuration
   - Check trust/untrust subnet configurations

### Debugging Commands

```bash
# Check storage account status
az storage account show --name <storage-account-name> --resource-group storage-static-website-example

# List storage blobs
az storage blob list --account-name <storage-account-name> --container-name '$web'

# Test website connectivity
curl -I http://<ngfw-public-ip>

# Check NGFW status
az palo-alto cloudngfw firewall show --name pangfw-staticweb-example --resource-group ngfw-static-website-example
```

## Troubleshooting

### Common Errors

#### 1. MissingSubscriptionRegistration Error
```
Error: performing CreateOrUpdate: unexpected status 409 (409 Conflict) with error: MissingSubscriptionRegistration: The subscription is not registered to use namespace 'PaloAltoNetworks.Cloudngfw'
```

**Solution**: Register the PaloAlto resource provider as described in Prerequisites.

#### 2. SecurityRuleInvalidPortRange Error
```
Error: Security rule has invalid Port range. Value provided: 80,443. Value should be an integer OR integer range with '-' delimiter.
```

**Solution**: This has been fixed in the configuration. Port ranges should use:
- Single range: `"80-443"`
- Multiple ports: `["80", "443"]` with `destination_port_ranges`

#### 3. Validation of Registration Status
```bash
# Verify provider registration
az provider list --query "[?namespace=='PaloAltoNetworks.Cloudngfw'].{Provider:namespace, State:registrationState}" --output table

# Expected output should show 'Registered'
```

## Security Considerations

1. **Network Segmentation**: Backend services properly isolated
2. **Access Control**: Storage restricted to designated subnets
3. **Threat Prevention**: NGFW inspects all traffic for threats
4. **Logging**: Comprehensive audit trail of all activities
5. **Secure Communication**: HTTPS can be configured with certificates

## Cost Optimization

1. **Storage Tier**: Use appropriate replication type (LRS for single region)
2. **NGFW Sizing**: Choose appropriate instance size for traffic volume
3. **Monitoring**: Set up cost alerts and resource utilization monitoring
4. **Lifecycle Management**: Configure blob lifecycle policies if needed

## Next Steps

1. **Custom Domain**: Configure custom domain name and SSL certificate
2. **Advanced Security**: Enable additional NGFW security features
3. **CI/CD Pipeline**: Automate content deployment and updates
4. **Performance Monitoring**: Set up comprehensive monitoring and alerting
5. **Backup Strategy**: Configure backup and disaster recovery procedures

## Architecture Benefits

- **Enterprise Security**: Next-generation firewall protection
- **Scalability**: Azure Storage handles high traffic loads
- **Cost-Effective**: Static hosting with enterprise security
- **Compliance**: Comprehensive logging and security controls
- **Performance**: Low-latency content delivery
- **Maintenance**: Infrastructure as Code for consistent deployments