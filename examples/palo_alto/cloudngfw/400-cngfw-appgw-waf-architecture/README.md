# Cloud NGFW with Application Gateway and WAF - Production Architecture

## Overview

This example demonstrates the **Microsoft recommended architecture** for deploying **Palo Alto Networks Cloud NGFW for Azure** behind **Azure Application Gateway with Web Application Firewall (WAF)**.

This architecture combines:

- **Layer 7 Protection**: Azure Application Gateway with WAF for web application security
- **Layer 4-7 Inspection**: Cloud NGFW for comprehensive network security with threat prevention
- **Centralized Policy Management**: Azure Rulestack for security policy management

## Architecture Diagram

```
Internet
    │
    ├──> Azure Application Gateway (WAF)
    │         │
    │         ├──> WAF Policies (OWASP, Bot Protection)
    │         │
    │         └──> Frontend Listener (HTTPS:443)
    │
    └──> User-Defined Routes (UDR)
              │
              ├──> Palo Alto Cloud NGFW
              │         │
              │         ├──> Local Rulestack
              │         │     ├──> Security Rules
              │         │     ├──> Threat Prevention
              │         │     ├──> URL Filtering
              │         │     └──> DNS Security
              │         │
              │         └──> Network Profile
              │               ├──> Trust Subnet (Private)
              │               └──> Untrust Subnet (Public)
              │
              └──> Backend Pool (Web/App Servers)
```

## Architecture Components

### 1. Azure Application Gateway with WAF

- **SKU**: WAF_v2 with zone redundancy
- **Features**:
  - OWASP 3.2 Core Rule Set
  - Bot Protection (Good/Bad/Unknown bots)
  - Custom rules for geo-filtering and rate limiting
  - SSL/TLS termination
  - HTTP to HTTPS redirection
  - Autoscaling (2-10 instances)

### 2. Palo Alto Cloud NGFW

- **Management**: Azure Local Rulestack
- **Features**:
  - App-ID technology for application identification
  - Advanced Threat Prevention
  - Advanced URL Filtering
  - DNS Security
  - SSL/TLS decryption (optional)
  - Egress NAT

### 3. Network Architecture

- **Hub VNet** (10.200.0.0/16):
  - Application Gateway Subnet (10.200.1.0/24)
  - NGFW Trust Subnet (10.200.10.0/24) - Delegated to Palo Alto
  - NGFW Untrust Subnet (10.200.11.0/24) - Delegated to Palo Alto
  - Backend Subnet (10.200.20.0/24)
  - Azure Bastion Subnet (10.200.250.0/24)

## Traffic Flow

### Inbound Web Traffic

1. **Internet → Application Gateway**:
   - Client HTTPS request arrives at AppGW public IP
   - WAF inspects at Layer 7 (SQL injection, XSS, etc.)
   - SSL/TLS termination at AppGW

2. **Application Gateway → Cloud NGFW**:
   - AppGW forwards to backend pool through UDR
   - Traffic routed to NGFW trust interface (10.200.10.4)
   - NGFW inspects traffic using App-ID and threat signatures

3. **Cloud NGFW → Backend**:
   - NGFW allows/denies based on security rules
   - Applies threat prevention profiles
   - Forwards legitimate traffic to backend servers

4. **Response Flow**:
   - Backend → NGFW → AppGW → Internet

### Outbound Traffic

1. Backend servers → NGFW (via UDR)
2. NGFW applies URL filtering, threat prevention, DNS security
3. NGFW → Internet (via egress NAT)

## Security Policies

### WAF Protection Layers

- **OWASP Top 10 Protection**: SQL injection, XSS, RCE, etc.
- **Bot Protection**: Blocks bad bots, allows good bots (search engines)
- **Geo-filtering**: Restricts access to allowed countries
- **Rate Limiting**: Prevents DDoS and brute-force attacks
- **Custom Rules**: Block known malicious IPs and suspicious user agents

### Cloud NGFW Security Rules

1. **Allow-Web-Traffic**:
   - Source: Application Gateway subnet
   - Destination: Backend subnet
   - Applications: web-browsing, ssl
   - Security Profiles: All enabled

2. **Allow-DNS**:
   - DNS queries with DNS Security inspection

3. **Deny-All** (Explicit):
   - Default deny rule with logging

### Security Services Enabled

- ✅ Advanced Threat Prevention (vulnerability, anti-spyware, antivirus)
- ✅ Advanced URL Filtering
- ✅ DNS Security
- ✅ File Blocking
- ✅ SSL Decryption (configurable)

## Best Practices Implemented

### Microsoft Azure Best Practices

✅ **Defense in Depth**: Multiple security layers (WAF + NGFW)
✅ **Zone Redundancy**: Resources deployed across availability zones
✅ **Network Segmentation**: Separate subnets for each tier
✅ **Least Privilege**: NSGs and security rules follow zero-trust principles
✅ **Logging & Monitoring**: Comprehensive diagnostic logs enabled
✅ **High Availability**: Autoscaling and zone-redundant deployment

### Palo Alto Best Practices

✅ **Native Policy Management**: Using Azure Rulestacks
✅ **App-ID**: Application-based security policies
✅ **Threat Prevention**: Real-time threat intelligence
✅ **SSL Inspection**: Decrypt and inspect encrypted traffic
✅ **Egress Filtering**: URL filtering for outbound traffic
✅ **DNS Security**: Block malicious domains

### WAF Best Practices

✅ **Prevention Mode**: Active blocking after tuning period
✅ **Latest Rulesets**: OWASP 3.2 and Bot Manager v1.0
✅ **Request Body Inspection**: Enabled for POST requests
✅ **Rule Exclusions**: Configured to reduce false positives
✅ **Geo-filtering**: Block unexpected geographic regions
✅ **Logging**: All requests logged to Log Analytics

## Deployment Instructions

### Prerequisites

- Azure subscription with appropriate permissions
- Terraform or Azure CLI installed
- Palo Alto Networks licensing (PAYG or BYOL)

### Multi-file Configuration Pattern

This example uses **multiple thematic `.tfvars` files** instead of a single `configuration.tfvars`, which is an allowed exception for complex scenarios requiring multiple domains.

**Configuration Files**:

- `global_settings.tfvars` - CAF global configuration (regions, randomness, defaults)
- `resource_groups.tfvars` - Resource group definitions
- `role_mapping.tfvars` - RBAC for operators and managed identities
- `managed_identities.tfvars` - User-assigned managed identity for App Gateway
- `keyvault.tfvars` - Key Vault storing SSL certificates
- `vnets.tfvars` - Virtual network and subnets
- `network_security_group_definition.tfvars` - NSG rules
- `public_ip_addresses.tfvars` - Public IPs for AppGW, NGFW, Bastion
- `storage_account_static_website.tfvars` - Static website storage account + private endpoint
- `storage_account_blobs.tfvars` - Initial web content automatically uploaded
- `private_dns.tfvars` - Private DNS zone for storage account private endpoint
- `log_analytics.tfvars` - Central Log Analytics workspace plus diagnostic destinations
- `application_gateway.tfvars` - Application Gateway configuration
- `application_gateway_applications.tfvars` - AppGW listeners, rules, pools
- `waf.tfvars` - WAF policies (OWASP, Bot Protection, custom rules)
- `cngfw.tfvars` - Cloud NGFW and rulestack configuration
- `udrs.tfvars` - User-defined route tables

**Var-file inventory**

| File                                       | Purpose                                                                                 | Mandatory                                          |
| ------------------------------------------ | --------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `global_settings.tfvars`                   | Defines CAF global settings (`default_region`, `regions`, `random_length`)              | ✅                                                 |
| `resource_groups.tfvars`                   | Creates shared resource groups                                                          | ✅                                                 |
| `role_mapping.tfvars`                      | Grants Key Vault Administrator to operator and certificate access to AppGW identity     | ✅                                                 |
| `managed_identities.tfvars`                | Provisions the App Gateway Key Vault user-assigned identity                             | ✅                                                 |
| `keyvault.tfvars`                          | Creates Key Vault and certificate                                                       | ✅                                                 |
| `public_ip_addresses.tfvars`               | Allocates public IPs for AppGW, NGFW, Bastion                                           | ✅                                                 |
| `vnets.tfvars`                             | Defines hub VNet, subnets, delegations, route-table bindings                            | ✅                                                 |
| `network_security_group_definition.tfvars` | NSG definitions for every subnet                                                        | ✅                                                 |
| `storage_account_static_website.tfvars`    | Storage account and private endpoint hosting the website                                | ✅                                                 |
| `storage_account_blobs.tfvars`             | Seeds `index.html` and `404.html` content                                               | Optional (remove if uploading content differently) |
| `private_dns.tfvars`                       | Private DNS zone for blob storage private endpoint resolution                           | ✅                                                 |
| `log_analytics.tfvars`                     | Central Log Analytics workspace plus diagnostics definition/destination for App Gateway | ✅                                                 |
| `application_gateway.tfvars`               | Core Application Gateway settings                                                       | ✅                                                 |
| `application_gateway_applications.tfvars`  | Listener/rule/backend composition                                                       | ✅                                                 |
| `waf.tfvars`                               | WAF policy definitions                                                                  | ✅                                                 |
| `cngfw.tfvars`                             | Palo Alto Cloud NGFW and rulestack policy                                               | ✅                                                 |
| `udrs.tfvars`                              | Route tables forcing traffic through NGFW                                               | ✅                                                 |

**Important Notes**:

- Mandatory blocks (`global_settings`, `resource_groups`) already live in their own tfvars files; do not duplicate them elsewhere
- Remove `rg-` prefix from resource group names (azurecaf adds it automatically)
- Static website content is uploaded automatically through `storage_account_blobs.tfvars`; adjust or remove that file if you plan to publish different files manually
- `log_analytics.tfvars` wires the Application Gateway diagnostic profile to a concrete workspace; omit it only if you also drop diagnostics from `application_gateway.tfvars`
- For CI integration, consider creating an aggregate `configuration.tfvars` or listing all var-files in workflow JSON

**Invocation Example**:

```bash
terraform plan \
   -var-file="global_settings.tfvars" \
   -var-file="resource_groups.tfvars" \
   -var-file="role_mapping.tfvars" \
   -var-file="managed_identities.tfvars" \
   -var-file="keyvault.tfvars" \
   -var-file="vnets.tfvars" \
   -var-file="network_security_group_definition.tfvars" \
   -var-file="public_ip_addresses.tfvars" \
   -var-file="application_gateway.tfvars" \
   -var-file="application_gateway_applications.tfvars" \
   -var-file="waf.tfvars" \
   -var-file="cngfw.tfvars" \
   -var-file="udrs.tfvars" \
   -var-file="storage_account_static_website.tfvars" \
   -var-file="storage_account_blobs.tfvars" \
   -var-file="private_dns.tfvars" \
   -var-file="log_analytics.tfvars"
```

### Step 1: Review and Customize Configuration

1. Review `global_settings.tfvars` to confirm `default_region`, `regions`, and `random_length` match your landing zone standards
2. Review `resource_groups.tfvars` - Remove `rg-` prefix, update regions
3. Review `role_mapping.tfvars` - Verify RBAC assignments for operators and managed identities
4. Review `managed_identities.tfvars` - Confirm identity configuration for Application Gateway
5. Review `keyvault.tfvars` - Update certificate settings and access policies
6. Review `waf.tfvars` - Customize WAF rules, geo-filtering countries
7. Review `application_gateway.tfvars` - Update backend pool IPs, SSL certificates
8. Review `udrs.tfvars` - Update next-hop IPs after NGFW deployment

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment (using all var-files)
terraform plan \
   -var-file="global_settings.tfvars" \
   -var-file="resource_groups.tfvars" \
   -var-file="role_mapping.tfvars" \
   -var-file="managed_identities.tfvars" \
   -var-file="keyvault.tfvars" \
   -var-file="vnets.tfvars" \
   -var-file="network_security_group_definition.tfvars" \
   -var-file="public_ip_addresses.tfvars" \
   -var-file="application_gateway.tfvars" \
   -var-file="application_gateway_applications.tfvars" \
   -var-file="waf.tfvars" \
   -var-file="cngfw.tfvars" \
   -var-file="udrs.tfvars" \
   -var-file="storage_account_static_website.tfvars" \
   -var-file="storage_account_blobs.tfvars" \
   -var-file="private_dns.tfvars" \
   -var-file="log_analytics.tfvars"

# Deploy
terraform apply \
   -var-file="global_settings.tfvars" \
   -var-file="resource_groups.tfvars" \
   -var-file="role_mapping.tfvars" \
   -var-file="managed_identities.tfvars" \
   -var-file="keyvault.tfvars" \
   -var-file="vnets.tfvars" \
   -var-file="network_security_group_definition.tfvars" \
   -var-file="public_ip_addresses.tfvars" \
   -var-file="application_gateway.tfvars" \
   -var-file="application_gateway_applications.tfvars" \
   -var-file="waf.tfvars" \
   -var-file="cngfw.tfvars" \
   -var-file="udrs.tfvars" \
   -var-file="storage_account_static_website.tfvars" \
   -var-file="storage_account_blobs.tfvars" \
   -var-file="private_dns.tfvars" \
   -var-file="log_analytics.tfvars"
```

### Step 3: Configure Cloud NGFW

1. Access Azure Portal → Navigate to Cloud NGFW resource
2. Verify Rulestack deployment
3. Review security rules in Rulestack
4. Enable security services (Threat Prevention, URL Filtering, DNS Security)
5. Deploy configuration

### Step 4: Update User-Defined Routes

After NGFW deployment, update UDR next-hop IP addresses:

1. Get NGFW trust interface private IP
2. Update `udrs.tfvars` route table next-hop IPs (replace placeholder `10.200.10.4`)
3. Reapply Terraform configuration with all var-files

### Step 5: Test and Validate

1. **Test WAF**:

   ```bash
   # Test SQL injection detection
   curl "https://app.example.com/?id=1' OR '1'='1"

   # Test XSS detection
   curl "https://app.example.com/?search=<script>alert(1)</script>"
   ```

2. **Test NGFW**:
   - Attempt to access blocked URLs
   - Test application-based policies
   - Verify threat prevention logs

3. **Monitor Logs**:
   - Application Gateway logs
   - WAF logs
   - Cloud NGFW logs

### Step 6: Tune WAF Policies

1. Start with **Detection Mode** for 1-2 weeks
2. Review logs in Log Analytics
3. Create rule exclusions for false positives
4. Switch to **Prevention Mode**

| ------------------------------------------ | --------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `global_settings.tfvars` | Defines CAF global settings (`default_region`, `regions`, `random_length`) | ✅ |
| `resource_groups.tfvars` | Creates shared resource groups | ✅ |
| `role_mapping.tfvars` | Grants Key Vault Administrator to operator and certificate access to AppGW identity | ✅ |
| `managed_identities.tfvars` | Provisions the App Gateway Key Vault user-assigned identity | ✅ |
| `keyvault.tfvars` | Creates Key Vault and certificate | ✅ |
| `public_ip_addresses.tfvars` | Allocates public IPs for AppGW, NGFW, Bastion | ✅ |
| `vnets.tfvars` | Defines hub VNet, subnets, delegations, route-table bindings | ✅ |
| `network_security_group_definition.tfvars` | NSG definitions for every subnet | ✅ |
| `storage_account_static_website.tfvars` | Storage account and private endpoint hosting the website | ✅ |
| `storage_account_blobs.tfvars` | Seeds `index.html` and `404.html` content | Optional (remove if uploading content differently) |
| `private_dns.tfvars` | Private DNS zone for blob storage private endpoint resolution | ✅ |
| `log_analytics.tfvars` | Central Log Analytics workspace plus diagnostics definition/destination for App Gateway | ✅ |
| `application_gateway.tfvars` | Core Application Gateway settings | ✅ |
| `application_gateway_applications.tfvars` | Listener/rule/backend composition | ✅ |
| `waf.tfvars` | WAF policy definitions | ✅ |
| `cngfw.tfvars` | Palo Alto Cloud NGFW and rulestack policy | ✅ |
| `udrs.tfvars` | Route tables forcing traffic through NGFW | ✅ |

**Important Notes**:

- Mandatory blocks (`global_settings`, `resource_groups`) already live in their own tfvars files; do not duplicate them elsewhere
- Remove `rg-` prefix from resource group names (azurecaf adds it automatically)
- Static website content is uploaded automatically through `storage_account_blobs.tfvars`; adjust or remove that file if you plan to publish different files manually
- `log_analytics.tfvars` wires the Application Gateway diagnostic profile to a concrete workspace; omit it only if you also drop diagnostics from `application_gateway.tfvars`
- For CI integration, consider creating an aggregate `configuration.tfvars` or listing all var-files in workflow JSON

**Invocation Example**:

```bash
terraform plan \
  -var-file="resource_groups.tfvars" \
  -var-file="vnets.tfvars" \
  -var-file="network_security_group_definition.tfvars" \
  -var-file="public_ip_addresses.tfvars" \
  -var-file="application_gateway.tfvars" \
  -var-file="application_gateway_applications.tfvars" \
  -var-file="waf.tfvars" \
  -var-file="cngfw.tfvars" \
  -var-file="udrs.tfvars" \
  -var-file="storage_account_static_website.tfvars" \
   -var-file="storage_account_blobs.tfvars" \
   -var-file="private_dns.tfvars" \
   -var-file="log_analytics.tfvars"
```

### Step 1: Review and Customize Configuration

1. Review `resource_groups.tfvars` - Remove `rg-` prefix, update regions
2. Review `global_settings.tfvars` to confirm `default_region`, `regions`, and `random_length` match your landing zone standards
3. Review `waf.tfvars` - Customize WAF rules, geo-filtering countries
4. Review `application_gateway.tfvars` - Update backend pool IPs, SSL certificates
5. Review `udrs.tfvars` - Update next-hop IPs after NGFW deployment

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment (using all var-files)
terraform plan \
  -var-file="resource_groups.tfvars" \
  -var-file="vnets.tfvars" \
  -var-file="network_security_group_definition.tfvars" \
  -var-file="public_ip_addresses.tfvars" \
  -var-file="application_gateway.tfvars" \
  -var-file="application_gateway_applications.tfvars" \
  -var-file="waf.tfvars" \
  -var-file="cngfw.tfvars" \
  -var-file="udrs.tfvars" \
  -var-file="storage_account_static_website.tfvars" \
   -var-file="storage_account_blobs.tfvars" \
   -var-file="private_dns.tfvars" \
   -var-file="log_analytics.tfvars"

# Deploy
terraform apply \
  -var-file="resource_groups.tfvars" \
  -var-file="vnets.tfvars" \
  -var-file="network_security_group_definition.tfvars" \
  -var-file="public_ip_addresses.tfvars" \
  -var-file="application_gateway.tfvars" \
  -var-file="application_gateway_applications.tfvars" \
  -var-file="waf.tfvars" \
  -var-file="cngfw.tfvars" \
  -var-file="udrs.tfvars" \
  -var-file="storage_account_static_website.tfvars" \
   -var-file="storage_account_blobs.tfvars" \
   -var-file="private_dns.tfvars" \
   -var-file="log_analytics.tfvars"
```

### Step 3: Configure Cloud NGFW

1. Access Azure Portal → Navigate to Cloud NGFW resource
2. Verify Rulestack deployment
3. Review security rules in Rulestack
4. Enable security services (Threat Prevention, URL Filtering, DNS Security)
5. Deploy configuration

### Step 4: Update User-Defined Routes

After NGFW deployment, update UDR next-hop IP addresses:

1. Get NGFW trust interface private IP
2. Update `udrs.tfvars` route table next-hop IPs (replace placeholder `10.200.10.4`)
3. Reapply Terraform configuration with all var-files

### Step 5: Test and Validate

1. **Test WAF**:

   ```bash
   # Test SQL injection detection
   curl "https://app.example.com/?id=1' OR '1'='1"

   # Test XSS detection
   curl "https://app.example.com/?search=<script>alert(1)</script>"
   ```

2. **Test NGFW**:
   - Attempt to access blocked URLs
   - Test application-based policies
   - Verify threat prevention logs

3. **Monitor Logs**:
   - Application Gateway logs
   - WAF logs
   - Cloud NGFW logs

### Step 6: Tune WAF Policies

1. Start with **Detection Mode** for 1-2 weeks
2. Review logs in Log Analytics
3. Create rule exclusions for false positives
4. Switch to **Prevention Mode**

## Cost Considerations

### Application Gateway WAF_v2

- Base cost: ~$0.443/hour
- Capacity units: Variable based on traffic
- Data processing: ~$0.008/GB

### Palo Alto Cloud NGFW

- PAYG: Hourly + data processing charges
- BYOL: Bring existing credits
- Check Azure Marketplace for current pricing

### Optimization Tips

- Use autoscaling to match demand
- Implement connection draining
- Enable caching where appropriate
- Consider reserved capacity for predictable workloads

## Monitoring and Operations

### Key Metrics to Monitor

**Application Gateway**:

- Healthy/Unhealthy host count
- Failed requests
- Response time
- Throughput

**WAF**:

- Blocked requests
- Top triggered rules
- False positive rate
- Geo-distribution of threats

**Cloud NGFW**:

- Threat count and severity
- Policy hits
- Bandwidth utilization
- Session count

### Log Analytics Queries

```kusto
// WAF Blocked Requests
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| where action_s == "Blocked"
| summarize count() by clientIp_s, Message

// Top Triggered WAF Rules
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| summarize count() by ruleId_s, Message
| top 10 by count_

// NGFW Threats Detected
PaloAltoNetworksCloudNGFW
| where Severity >= 3
| summarize count() by ThreatName, SourceIP
| top 20 by count_
```

### Alerting

Configure alerts for:

- High number of blocked requests
- Backend unhealthy hosts
- NGFW high threat severity events
- Unusual traffic patterns

## Security Considerations

### Certificate Management

- Store SSL certificates in Azure Key Vault
- Enable certificate auto-renewal
- Use managed identities for Key Vault access

### Secrets Management

- Never commit secrets to source control
- Use Azure Key Vault for all secrets
- Implement RBAC for Key Vault access

### Network Security

- NSGs implement least privilege access
- Regular review of security rules
- Enable NSG flow logs
- Implement Azure DDoS Protection

### Compliance

- Enable Azure Policy for governance
- Tag all resources appropriately
- Implement Azure Blueprints
- Regular security assessments

## Troubleshooting

### Common Issues

**1. Application Gateway Backend Unhealthy**

- Check NSG rules on backend subnet
- Verify health probe configuration
- Ensure backend servers are responding to probes
- Review UDR next-hop IP address

**2. WAF False Positives**

- Review WAF logs in Log Analytics
- Identify triggered rule IDs
- Add rule exclusions as needed
- Consider Detection mode for testing

**3. NGFW Traffic Not Flowing**

- Verify subnet delegation to PaloAltoNetworks.Cloudngfw/firewalls
- Check NGFW security rules
- Validate public IP assignments
- Review rulestack deployment status

**4. SSL/TLS Issues**

- Verify certificate validity
- Check SSL policy compatibility
- Ensure proper certificate chain
- Review cipher suite configuration

## References

### Microsoft Documentation

- [Cloud NGFW for Azure deployment behind Azure Application Gateway](https://learn.microsoft.com/en-us/azure/partner-solutions/palo-alto/application-gateway)
- [Best practices for Azure Web Application Firewall](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/best-practices)
- [Secure your Azure Web Application Firewall deployment](https://learn.microsoft.com/en-us/azure/web-application-firewall/secure-web-application-firewall)
- [What is Cloud NGFW by Palo Alto Networks](https://learn.microsoft.com/en-us/azure/partner-solutions/palo-alto/palo-alto-overview)

### Palo Alto Networks Documentation

- [Cloud NGFW for Azure](https://docs.paloaltonetworks.com/cloud-ngfw/azure)
- [Native Policy Management Using Rulestacks](https://docs.paloaltonetworks.com/cloud-ngfw/azure/cloud-ngfw-for-azure/native-policy-management)

## Support

For issues related to:

- **Terraform/CAF**: Open issue in repository
- **Azure Services**: Azure Support Portal
- **Palo Alto NGFW**: Palo Alto Networks Support

## License

This example is provided as-is for reference purposes.

---

**Version**: 1.0  
**Last Updated**: October 2025  
**Tested With**:

- Terraform 1.5+
- Azure CAF Terraform Module
- Cloud NGFW for Azure (Latest)
- Application Gateway WAF_v2
