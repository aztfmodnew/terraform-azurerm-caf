# Azure Front Door Static Website Example

This example demonstrates how to deploy a static website using Azure Storage Account static website hosting with Azure Front Door for global content delivery and enhanced performance.

## Architecture Overview

```
[User] 
    ↓
[Azure Front Door] 
    ↓ 
[Storage Account - Static Website]
    ↓
[Log Analytics + Diagnostic Storage]
```

The solution includes:

- **Azure Storage Account**: Hosts the static website with HTML/CSS/JS files
- **Azure Front Door**: Global CDN for content delivery and security
- **Log Analytics Workspace**: Centralized logging for monitoring and analytics
- **Diagnostic Storage Account**: Long-term storage of diagnostic logs
- **Resource Group**: Contains all the resources

## Key Features

### Static Website Hosting
- HTML, CSS, and JavaScript files hosted on Azure Storage Account
- Custom error pages (404.html)
- Automatic content optimization and compression

### Azure Front Door
- Global CDN with 100+ edge locations
- Automatic SSL/TLS certificate management
- Web Application Firewall (WAF) protection
- Health monitoring and load balancing
- HTTP/2 support for improved performance

### Monitoring and Diagnostics
- Comprehensive diagnostic logging for Front Door
- Log Analytics workspace for centralized log analysis
- Storage account for long-term log retention
- Configurable retention policies for cost optimization

## Storage Account Retention Policies

### Static Website Storage Account
The static website storage account includes lifecycle management policies:

- **Short-term retention**: 7 days for blob deletion recovery
- **Tier optimization**: Content moves to cool tier after 30 days
- **Archive tier**: Content moves to archive after 90 days
- **Long-term cleanup**: Content deleted after 365 days

### Diagnostic Logs Storage Account
The diagnostic storage account includes specialized retention policies:

- **Front Door logs**: 90-day retention with tiering at 7 and 30 days
- **General logs**: 365-day retention for compliance
- **Cost optimization**: Automatic tiering to cool and archive tiers
- **Container retention**: 30-day soft delete protection

## Files Structure

```
103-frontdoor-static-website/
├── README.md                    # This documentation
├── configuration.tfvars         # Main configuration
├── resource_groups.tfvars       # Resource group definitions
├── storage_accounts.tfvars      # Static website storage and HTML content
├── cdn_frontdoor_profiles.tfvars # Front Door configuration
└── diagnostics.tfvars          # Logging and monitoring setup
```

## Deployment

### Prerequisites

1. Azure CLI installed and authenticated
2. Terraform >= 1.6.0
3. AzureRM Provider >= 4.0.0

### Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Azure/terraform-azurerm-caf.git
   cd terraform-azurerm-caf
   ```

2. **Navigate to the example**:
   ```bash
   cd examples/networking/front_door/103-frontdoor-static-website
   ```

3. **Initialize Terraform**: 
   ```bash
   terraform init
   ```

4. **Plan Deployment**:
   ```bash
   terraform plan \
     -var-file=resource_groups.tfvars \
     -var-file=storage_accounts.tfvars \
     -var-file=cdn_frontdoor_profiles.tfvars \
     -var-file=diagnostics.tfvars \
     -var-file=configuration.tfvars
   ```

5. **Apply Configuration**:
   ```bash
   terraform apply \
     -var-file=resource_groups.tfvars \
     -var-file=storage_accounts.tfvars \
     -var-file=cdn_frontdoor_profiles.tfvars \
     -var-file=diagnostics.tfvars \
     -var-file=configuration.tfvars
   ```

## Cost Optimization

The example includes several cost optimization features:

### Storage Tiering
- **Hot tier**: Frequently accessed content
- **Cool tier**: Infrequently accessed content (after 30 days)
- **Archive tier**: Long-term storage (after 90 days)

### Log Retention
- **Diagnostic logs**: Automated cleanup after 90-365 days
- **Metrics retention**: Configurable in Log Analytics (30 days default)
- **Blob soft delete**: 7-30 day protection without long-term costs

### Front Door Optimization
- Compression enabled for bandwidth savings
- Caching rules for reduced origin requests
- Health probes optimized for minimal costs

## Security Features

### Network Security
- Storage account allows Azure service access
- Front Door provides DDoS protection
- Optional WAF rules for application security

### SSL/TLS
- Automatic certificate provisioning and renewal
- HTTPS redirect capabilities
- Modern TLS protocols supported

### Access Control
- Storage account configured for static website access
- Front Door origin security with custom headers
- Diagnostic logs access controlled via RBAC

## Monitoring and Alerting

### Available Logs
- **FrontDoorAccessLog**: All requests to Front Door
- **FrontDoorHealthProbeLog**: Health check results
- **FrontDoorWebApplicationFirewallLog**: WAF events
- **AllMetrics**: Performance and usage metrics

### Key Metrics to Monitor
- Request count and latency
- Cache hit ratio
- Origin health status
- Bandwidth utilization
- Error rates (4xx, 5xx)

## Customization Options

### Domain Configuration
- Add custom domain to Front Door
- Configure SSL certificate
- Set up DNS CNAME records

### WAF Rules
- Enable Web Application Firewall
- Configure custom security rules
- Set up rate limiting

### Caching Behavior
- Configure cache TTL values
- Set up custom caching rules
- Enable/disable compression

### Content Updates
- Upload new content to storage account
- Front Door will automatically distribute updates
- Configure cache purging if needed

## Best Practices

1. **Use descriptive resource names** following Azure naming conventions
2. **Tag all resources** for proper cost allocation and management
3. **Monitor costs regularly** using Azure Cost Management
4. **Set up alerts** for unusual traffic patterns or errors
5. **Regular backup** of static content before updates
6. **Review logs periodically** for security and performance insights
7. **Update retention policies** based on compliance requirements

## Troubleshooting

### Common Issues
- **404 errors**: Check that index.html exists in the $web container
- **SSL certificate issues**: Verify domain ownership and DNS configuration
- **High costs**: Review retention policies and storage tiering settings
- **Performance issues**: Check Front Door health probes and cache settings

### Useful Commands
```bash
# Check Front Door endpoint status
az network front-door show --name <front-door-name> --resource-group <rg-name>

# List storage account containers
az storage container list --account-name <storage-account-name>

# View diagnostic logs
az monitor diagnostic-settings list --resource <front-door-resource-id>
```

## Support and Documentation

- [Azure Front Door Documentation](https://docs.microsoft.com/en-us/azure/frontdoor/)
- [Azure Storage Static Website](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website)
- [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

3. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

4. **Planificar el despliegue**:
   ```bash
   terraform plan \
     -var-file="configuration.tfvars" \
     -var-file="storage_accounts.tfvars" \
     -var-file="cdn_frontdoor_profiles.tfvars" \
     -var-file="diagnostics.tfvars"
   ```

5. **Aplicar la configuración**:
   ```bash
   terraform apply \
     -var-file="configuration.tfvars" \
     -var-file="storage_accounts.tfvars" \
     -var-file="cdn_frontdoor_profiles.tfvars" \
     -var-file="diagnostics.tfvars"
   ```

## 🔧 Personalización

### Dominio personalizado

Para usar un dominio personalizado, modifica `cdn_frontdoor_profiles.tfvars`:

```hcl
custom_domains = {
  ejemplo = {
    name      = "mi-sitio-personalizado"
    host_name = "www.ejemplo.com"
    tls = {
      certificate_type    = "ManagedCertificate"
      minimum_tls_version = "TLS12"
    }
  }
}
```

### WAF (Web Application Firewall)

Para añadir protección WAF, agrega en `cdn_frontdoor_profiles.tfvars`:

```hcl
firewall_policies = {
  main_waf = {
    name = "waf-policy"
    mode = "Prevention"
    
    managed_rules = {
      default_rule_set = {
        type    = "Microsoft_DefaultRuleSet"
        version = "2.1"
      }
    }
  }
}
```

### Contenido del sitio web

Modifica los bloques `storage_account_blobs` en `storage_accounts.tfvars` para personalizar el contenido HTML, CSS y JavaScript.

## 📊 Monitoreo y Logs

Este ejemplo incluye configuración completa de monitoreo:

- **Log Analytics Workspace**: Para centralizar todos los logs
- **Diagnostic Settings**: Captura de logs de acceso, health probes y WAF
- **Métricas**: Disponibles en Azure Monitor para análisis de rendimiento

### Consultas útiles de Log Analytics

**Top 10 URLs más visitadas**:
```kusto
AzureDiagnostics
| where Category == "FrontDoorAccessLog"
| summarize Requests = count() by requestUri_s
| top 10 by Requests
```

**Errores 4xx y 5xx**:
```kusto
AzureDiagnostics
| where Category == "FrontDoorAccessLog" 
| where httpStatusCode_d >= 400
| summarize Errors = count() by httpStatusCode_d, requestUri_s
```

## 🔒 Seguridad

El ejemplo implementa las siguientes medidas de seguridad:

- **HTTPS Forzado**: Todo el tráfico se redirige a HTTPS
- **Security Headers**: 
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY`
  - `X-XSS-Protection: 1; mode=block`
  - `Strict-Transport-Security: max-age=31536000`
  - `Referrer-Policy: strict-origin-when-cross-origin`

## 💰 Costos estimados

Para un sitio web con tráfico moderado (10GB/mes):

- **Azure Front Door Standard**: ~$22.00/mes
- **Storage Account (LRS)**: ~$0.50/mes  
- **Log Analytics (5GB)**: ~$2.50/mes
- **Total**: ~$25.00/mes

*Los precios pueden variar según la región y el uso real.*

## 🎯 Casos de uso

Este patrón es ideal para:

- Sitios web corporativos estáticos
- Landing pages de marketing
- Documentación técnica
- Blogs estáticos (Jekyll, Hugo, etc.)
- SPAs (Single Page Applications) 
- Sitios web de portafolio

## 🔧 Troubleshooting

### Error: "Storage account not found"
Verifica que el nombre del Storage Account sea único globalmente.

### Error: "Front Door endpoint not accessible"
El despliegue puede tardar 5-10 minutos en propagar globalmente.

### Error: "SSL certificate provisioning failed"
Los certificados SSL gratuitos pueden tardar hasta 24 horas en provisionarse.

## 📚 Referencias

- [Azure Front Door documentation](https://docs.microsoft.com/azure/frontdoor/)
- [Static website hosting in Azure Storage](https://docs.microsoft.com/azure/storage/blobs/storage-blob-static-website)
- [Terraform Azure CAF](https://github.com/Azure/terraform-azurerm-caf)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o envía un pull request.

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](../../../../LICENSE) para más detalles.
