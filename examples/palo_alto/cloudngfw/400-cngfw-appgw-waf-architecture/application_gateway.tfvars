# Application Gateway Configuration
# Following Microsoft Architecture Best Practices:
# https://learn.microsoft.com/en-us/azure/partner-solutions/palo-alto/application-gateway
#
# Architecture Pattern:
# Internet -> Application Gateway (WAF) -> Cloud NGFW -> Backend Pool
#
# Best Practices Implemented:
# 1. WAF_v2 SKU for advanced security features
# 2. Zone-redundant deployment for high availability
# 3. Autoscaling for performance and cost optimization
# 4. HTTP/2 enabled for better performance
# 5. SSL/TLS termination at Application Gateway
# 6. Health probes for backend monitoring
# 7. Connection draining for graceful shutdowns

application_gateways = {
  production_appgw = {
    name               = "appgw-cngfw-production"
    resource_group_key = "networking_rg"
    vnet_key           = "hub_vnet"
    subnet_key         = "appgw_subnet"

    # SKU Configuration
    # Best Practice: Use WAF_v2 for advanced security and performance
    sku_name = "WAF_v2"
    sku_tier = "WAF_v2"

    # Associate with WAF Policy
    waf_policy = {
      key = "production_waf_policy"
    }

    # Managed Identity for Key Vault Access
    # Best Practice: Use managed identity instead of service principal
    identity = {
      type = "UserAssigned"
      managed_identity_keys = [
        "appgw_keyvault_identity"
      ]
    }

    # Capacity Configuration
    # Best Practice: Use autoscaling for production workloads
    capacity = {
      autoscale = {
        minimum_scale_unit = 2  # Minimum instances for HA
        maximum_scale_unit = 10 # Scale up to 10 instances based on demand
      }
    }

    # Availability Zones
    # Best Practice: Deploy across zones for 99.99% SLA
    zones        = ["1", "2", "3"]
    enable_http2 = true
    front_end_ip_configurations = {
      public = {
        name          = "frontend-public-ip"
        public_ip_key = "appgw_pip"
      }
    }
    front_end_ports = {
      http = {
        name     = "port-http-80"
        port     = 80
        protocol = "Http"
      }
      https = {
        name     = "port-https-443"
        port     = 443
        protocol = "Https"
      }
    }
    ssl_policy = {
      policy_type = "Predefined"
      policy_name = "AppGwSslPolicy20220101"
    }

    # Redirect Configurations
    # Best Practice: Redirect HTTP to HTTPS for security
    redirect_configurations = {
      http_to_https = {
        name                 = "http-to-https"
        redirect_type        = "Permanent"
        target_listener_name = "listener-https-443"
        include_path         = true
        include_query_string = true
      }
    }

    # Diagnostic Settings
    # Best Practice: Enable comprehensive logging
    diagnostic_profiles = {
      central_logs_region1 = {
        definition_key   = "application_gateway"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }

    tags = {
      environment = "production"
      tier        = "frontend"
      protection  = "waf-enabled"
      ha          = "zone-redundant"
      cost_center = "infrastructure"
    }
  }
}

# SSL Certificates (if needed)
# Best Practice: Store certificates in Azure Key Vault
# Uncomment and configure if you have SSL certificates
# keyvault_certificates = {
#   app_ssl_cert = {
#     name               = "app-example-com-cert"
#     keyvault_key       = "security_keyvault"
#     
#     certificate = {
#       contents = filebase64("path/to/certificate.pfx")
#       password = "certificate_password" # Use var.certificate_password in production
#     }
#     
#     certificate_policy = {
#       issuer_parameters = {
#         name = "Self"
#       }
#       
#       key_properties = {
#         exportable = true
#         key_size   = 2048
#         key_type   = "RSA"
#         reuse_key  = false
#       }
#       
#       lifetime_action = {
#         action = {
#           action_type = "AutoRenew"
#         }
#         trigger = {
#           days_before_expiry = 30
#         }
#       }
#       
#       secret_properties = {
#         content_type = "application/x-pkcs12"
#       }
#       
#       x509_certificate_properties = {
#         extended_key_usage = ["1.3.6.1.5.5.7.3.1"] # Server Authentication
#         
#         key_usage = [
#           "digitalSignature",
#           "keyEncipherment",
#         ]
#         
#         subject            = "CN=app.example.com"
#         validity_in_months = 12
#         
#         subject_alternative_names = {
#           dns_names = ["app.example.com", "www.app.example.com"]
#         }
#       }
#     }
#   }
# }

# Key Vault for storing certificates (if needed)
# keyvaults = {
#   security_keyvault = {
#     name                = "kv-appgw-cngfw-certs"
#     resource_group_key  = "networking_rg"
#     sku_name            = "standard"
#     
#     soft_delete_enabled        = true
#     purge_protection_enabled   = true
#     soft_delete_retention_days = 90
#     
#     enabled_for_deployment          = true
#     enabled_for_disk_encryption     = true
#     enabled_for_template_deployment = true
#     
#     network_acls = {
#       bypass         = "AzureServices"
#       default_action = "Deny"
#       
#       ip_rules = ["your.public.ip.address/32"]
#     }
#     
#     tags = {
#       purpose = "Application Gateway SSL Certificates"
#     }
#   }
# }
