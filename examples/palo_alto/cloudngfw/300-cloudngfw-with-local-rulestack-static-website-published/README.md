# Palo Alto Cloud NGFW with Static Website and Virtual Machine

This example demonstrates how to deploy a Palo Alto Cloud NGFW to protect both a static website hosted on Azure Storage and a Linux virtual machine with web server in a hub-and-spoke architecture.

## Architecture Overview

```
                        ┌─── Internet ───┐
                        │                │
                        ▼                ▼
            ┌─── Palo Alto Cloud NGFW ───┐
            │    (Hub Network)           │
            │  - Management              │
            │  - Trust/Untrust           │
            │  - Security Policies       │
            └────────────┬───────────────┘
                         │
            ┌────────────▼───────────────┐
            │     Spoke Network          │
            │  ┌─────────────────────┐   │
            │  │  Static Website     │   │
            │  │  (Azure Storage)    │   │
            │  └─────────────────────┘   │
            │  ┌─────────────────────┐   │
            │  │  Linux VM           │   │
            │  │  (Nginx Web Server) │   │
            │  └─────────────────────┘   │
            └────────────────────────────┘
```

This setup provides enterprise-grade security for both static and dynamic web content using:
- **Palo Alto Cloud NGFW** with local rulestack for centralized security policies
- **Azure Storage Account** with static website hosting and private endpoints
- **Linux Virtual Machine** with Nginx web server
- **Hub-and-spoke architecture** with VNet peering
- **Network segmentation** with dedicated subnets and route tables
- **DNAT configuration** for external access through the firewall

## Components

### 1. Network Infrastructure
#### Hub Network (10.100.0.0/16)
- **Management subnet** (10.100.1.0/24) - NGFW management interface
- **Trust subnet** (10.100.2.0/24) - Internal trusted network for inspection
- **Untrust subnet** (10.100.3.0/24) - Internet-facing traffic
- **Transit subnet** (10.100.4.0/24) - Hub-to-spoke routing

#### Spoke Network (10.200.0.0/16)
- **Backend subnet** (10.200.1.0/24) - Storage private endpoints
- **Web tier subnet** (10.200.2.0/24) - Reserved for web services
- **VM subnet** (10.200.3.0/24) - Virtual machine workloads
- **Public IPs**: Management and dataplane access for NGFW
- **Network Security Groups**: Layer 4 security controls for each subnet
- **Route Tables**: Direct traffic through NGFW for inspection

### 2. Palo Alto Cloud NGFW
- **Management Mode**: Local Rulestack for policy management
- **Attachment Type**: VNet with delegated subnets
- **Security Features**: 
  - Traffic inspection and logging for both static and dynamic content
  - Threat prevention capabilities
  - Application-level filtering
  - DNAT rules for external access
  - NAT and egress capabilities for outbound traffic

### 3. Workload Services
#### Azure Storage Account
- **Type**: StorageV2 with static website hosting enabled
- **Content**: Professional static website demonstrating security features
- **Access Control**: Private endpoints for secure backend access
- **CORS**: Configured for web browsers

#### Linux Virtual Machine
- **OS**: Ubuntu 20.04 LTS
- **Size**: Standard_B2s (cost-optimized)
- **Web Server**: Nginx with custom website
- **Identity**: System-assigned managed identity
- **Access**: SSH and web services via NGFW DNAT
- **Auto-shutdown**: Configured for cost optimization

### 4. Security Configuration
#### NGFW Security Rules
- **Inbound Rules**: Target NGFW public IP specifically for DNAT processing
- **SSH Access**: External SSH to VM via DNAT (port 2022 → 22)
- **Web Traffic**: HTTP/HTTPS access to both static site and VM via NGFW public IP
- **Outbound Traffic**: VM internet access through NGFW inspection
- **Inter-subnet Communication**: Controlled access between spoke services

**Key Security Principle**: All inbound rules target the NGFW's public IP address (`public_ip_address_keys = ["ngfw_pip_dataplane1"]`) rather than broad CIDR ranges, ensuring traffic flows through the firewall's DNAT engine for proper inspection and translation.

#### DNAT Configuration
- **Static Website**: NGFW_IP:443 → Storage Private Endpoint:443
- **VM SSH**: NGFW_IP:2022 → VM:22
- **VM HTTP**: NGFW_IP:8080 → VM:80
- **VM HTTPS**: NGFW_IP:8443 → VM:443
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

## Accessing the Services

After successful deployment, you can access both the static website and virtual machine through the NGFW:

### 1. Get NGFW Public IP
```bash
# Get the IP from Terraform output
NGFW_IP=$(terraform output -raw objects | jq -r '.public_ip_addresses.ngfw_pip_dataplane1.ip_address')
echo "NGFW Public IP: $NGFW_IP"
```

### 2. Access Static Website
```bash
# HTTPS access to static website (Azure Storage requires HTTPS)
curl -k -v --connect-timeout 10 https://$NGFW_IP/

# Browser access: https://$NGFW_IP
# Note: SSL certificate warnings are expected
```

### 3. Access Virtual Machine
```bash
# SSH access (DNAT: external port 2022 → VM port 22)
ssh -p 2022 azureuser@$NGFW_IP

# HTTP web server access (DNAT: external port 8080 → VM port 80)
curl -v --connect-timeout 10 http://$NGFW_IP:8080/

# HTTPS web server access (DNAT: external port 8443 → VM port 443)
curl -k -v --connect-timeout 10 https://$NGFW_IP:8443/
```

### 4. VM Service Verification
```bash
# SSH into VM and check services
ssh -p 2022 azureuser@$NGFW_IP

# Inside VM - check web server status
sudo systemctl status nginx

# Test internet connectivity through NGFW
curl ifconfig.me

# Test connectivity to storage private endpoint
ping 10.200.1.4
```

## Traffic Flow Verification

### Inbound Traffic Testing
| Service | External Access | Expected Result |
|---------|-----------------|-----------------|
| Static Website | `https://$NGFW_IP:443` | Azure Storage content |
| VM SSH | `ssh -p 2022 azureuser@$NGFW_IP` | SSH session to VM |
| VM Web HTTP | `http://$NGFW_IP:8080` | Nginx welcome page |
| VM Web HTTPS | `https://$NGFW_IP:8443` | Nginx welcome page (SSL warning) |

### Outbound Traffic Testing
```bash
# From VM - verify outbound traffic goes through NGFW
ssh -p 2022 azureuser@$NGFW_IP "curl -s ifconfig.me"
# Should return NGFW's public IP, confirming traffic inspection
```

## Monitoring and Logging

### NGFW Monitoring
- Traffic flow logs through Palo Alto management interface
- Security events and threat detection alerts
- DNAT translation logs for external access tracking
- Application visibility for both static and dynamic content

### VM Monitoring
- **Boot Diagnostics**: Available in Azure portal
- **System Logs**: `/var/log/cloud-init-output.log` for setup verification
- **Web Server Logs**: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`
- **Auto-shutdown**: Configured for 10 PM UTC daily

### Storage Monitoring
- Private endpoint connectivity logs
- Blob access patterns and performance metrics
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

### Common Issues and Solutions

#### 1. Website/VM Access Issues
```bash
# Check if NGFW is fully deployed
az vm list -g $RESOURCE_GROUP --query "[?contains(name,'cloudngfw')].powerState" -o table

# Verify NSG rules allow traffic
az network nsg rule list -g $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[?direction=='Inbound' && access=='Allow']" -o table

# Test connectivity from local machine
nc -zv $NGFW_IP 443   # Static website HTTPS
nc -zv $NGFW_IP 2022  # VM SSH
nc -zv $NGFW_IP 8080  # VM HTTP
nc -zv $NGFW_IP 8443  # VM HTTPS
```

#### 2. DNAT/Traffic Flow Issues
```bash
# From VM - verify default route points to NGFW
ssh -p 2022 azureuser@$NGFW_IP "ip route show default"

# Should show: default via 10.200.0.4 dev eth0 (NGFW internal IP)

# Check VM can reach internet through NGFW
ssh -p 2022 azureuser@$NGFW_IP "curl -s --max-time 10 ifconfig.me"
```

#### 3. VM Service Issues
```bash
# Check VM status and boot diagnostics
az vm get-instance-view -g $RESOURCE_GROUP -n vm-linux-001 --query "instanceView.statuses[?starts_with(code, 'PowerState')]" -o table

# SSH to VM and check services
ssh -p 2022 azureuser@$NGFW_IP

# Inside VM:
sudo systemctl status nginx          # Web server status
sudo systemctl status cloud-init    # Cloud-init status
tail -f /var/log/cloud-init-output.log  # Setup logs
sudo netstat -tlnp | grep :80       # Check if nginx is listening
```

#### 4. Storage Private Endpoint Issues
```bash
# Test DNS resolution from VM
ssh -p 2022 azureuser@$NGFW_IP "nslookup $STORAGE_ACCOUNT.blob.core.windows.net"

# Should resolve to private IP (10.200.1.4)

# Test connectivity to storage
ssh -p 2022 azureuser@$NGFW_IP "nc -zv 10.200.1.4 443"
```

#### 5. Provider Registration Issues
```bash
# MissingSubscriptionRegistration Error Solution
az provider register --namespace PaloAltoNetworks.Cloudngfw

# Verify provider registration
az provider list --query "[?namespace=='PaloAltoNetworks.Cloudngfw'].{Provider:namespace, State:registrationState}" --output table
```

#### 6. SSL Certificate Warnings
- **Expected behavior**: Self-signed certificates generate browser warnings
- **For testing**: Use `curl -k` to ignore certificate errors
- **Production**: Replace with proper certificates from trusted CA

### Deployment Validation Checklist

- [ ] NGFW public IP accessible
- [ ] Static website loads via HTTPS
- [ ] VM SSH accessible on port 2022
- [ ] VM web services accessible on ports 8080/8443
- [ ] VM outbound traffic routes through NGFW
- [ ] Storage private endpoint resolves correctly
- [ ] All NSG rules configured properly
- [ ] Route tables directing traffic to NGFW

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