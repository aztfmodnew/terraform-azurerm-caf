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

### Step 1: Review and Customize Configuration
1. Review `resource_groups.tfvars` - Update network ranges, regions, naming
2. Review `waf.tfvars` - Customize WAF rules, geo-filtering countries
3. Review `application_gateway.tfvars` - Update backend pool IPs, SSL certificates

### Step 2: Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="configuration.tfvars" \
               -var-file="waf.tfvars" \
               -var-file="application_gateway.tfvars"

# Deploy
terraform apply -var-file="configuration.tfvars" \
                -var-file="waf.tfvars" \
                -var-file="application_gateway.tfvars"
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
2. Update `configuration.tfvars` route table next-hop IPs
3. Reapply Terraform configuration

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
