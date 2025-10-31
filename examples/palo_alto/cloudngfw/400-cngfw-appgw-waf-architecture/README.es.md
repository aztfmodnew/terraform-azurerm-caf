# Cloud NGFW with Application Gateway and WAF Architecture

Este ejemplo demuestra cómo desplegar la arquitectura recomendada por Microsoft para Palo Alto Networks Cloud NGFW detrás de Azure Application Gateway con WAF.

## Archivos de Configuración

- **configuration.tfvars**: Configuración base (VNets, subnets, NSGs, Public IPs, Cloud NGFW con rulestack, Route Tables)
- **waf.tfvars**: Políticas de WAF con reglas OWASP 3.2, Bot Protection, geo-filtering, y reglas personalizadas
- **application_gateway.tfvars**: Configuración de Application Gateway v2 con WAF integrado
- **README.md**: Documentación completa de la arquitectura

## Arquitectura

```
Internet → Application Gateway (WAF) → Cloud NGFW (Rulestack) → Backend Workloads
```

### Componentes de Seguridad

1. **Application Gateway WAF**:
   - OWASP Core Rule Set 3.2
   - Bot Protection
   - Geo-filtering
   - Rate Limiting
   - Custom Security Rules

2. **Palo Alto Cloud NGFW**:
   - Local Rulestack para gestión de políticas
   - App-ID para identificación de aplicaciones
   - Advanced Threat Prevention
   - Advanced URL Filtering
   - DNS Security
   - Egress NAT

3. **Network Security**:
   - NSGs con least-privilege access
   - User-Defined Routes (UDR)
   - Subnet delegation para NGFW
   - Zone-redundant deployment

## Despliegue Rápido

```bash
# Desde el directorio de ejemplos de CAF
terraform init

terraform plan \
  -var-file="palo_alto/cloudngfw/400-cngfw-appgw-waf-architecture/configuration.tfvars" \
  -var-file="palo_alto/cloudngfw/400-cngfw-appgw-waf-architecture/waf.tfvars" \
  -var-file="palo_alto/cloudngfw/400-cngfw-appgw-waf-architecture/application_gateway.tfvars"

terraform apply \
  -var-file="palo_alto/cloudngfw/400-cngfw-appgw-waf-architecture/configuration.tfvars" \
  -var-file="palo_alto/cloudngfw/400-cngfw-appgw-waf-architecture/waf.tfvars" \
  -var-file="palo_alto/cloudngfw/400-cngfw-appgw-waf-architecture/application_gateway.tfvars"
```

## Personalización

### Antes del Despliegue
1. Actualizar rangos de red en `configuration.tfvars` si es necesario
2. Modificar países permitidos en geo-filtering (archivo `waf.tfvars`)
3. Actualizar IPs de backend pool en `application_gateway.tfvars`
4. Configurar certificados SSL si se requiere HTTPS

### Después del Despliegue
1. Obtener la IP privada del trust interface del NGFW
2. Actualizar las route tables con la IP correcta
3. Validar el flujo de tráfico
4. Ajustar reglas de WAF según sea necesario (modo Detection → Prevention)

## Best Practices Implementadas

✅ **Microsoft Best Practices**:
- Arquitectura de defensa en profundidad
- Zone-redundant deployment
- Network segmentation
- Comprehensive logging

✅ **Palo Alto Best Practices**:
- Azure Rulestack para gestión nativa
- App-ID technology
- Threat prevention habilitada
- Security services configurados

✅ **WAF Best Practices**:
- Prevention mode (después de tuning)
- Latest OWASP rulesets
- Bot protection
- Request body inspection

## Referencias

- [Microsoft: Cloud NGFW behind Application Gateway](https://learn.microsoft.com/en-us/azure/partner-solutions/palo-alto/application-gateway)
- [Microsoft: WAF Best Practices](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/best-practices)
- [Palo Alto: Cloud NGFW for Azure](https://docs.paloaltonetworks.com/cloud-ngfw/azure)

---

Para documentación completa, ver [README.md](./README.md)
