# Key Vault Configuration for Azure Bot SSL Certificates
keyvaults = {
  bot_certificates_kv = {
    name               = "bot-ssl-certificates"
    resource_group_key = "bot_rg"
    sku_name           = "standard"

    # Enable for certificate management
    enabled_for_deployment          = true
    enabled_for_disk_encryption     = true
    enabled_for_template_deployment = true

    # Use RBAC for access control (recommended)
    enable_rbac_authorization = true

    # Retention settings
    soft_delete_retention_days = 30
    purge_protection_enabled   = false # Set to true for production

    # Network access
    network_acls = {
      default_action = "Allow" # Set to "Deny" and configure IP rules for production
    }

    tags = {
      architecture = "secure-bot"
      environment  = "production"
      cost_center  = "it-security"
      service      = "key-vault"
      purpose      = "ssl-certificate-storage"
      example      = "azure-bot-waf-private-endpoint"
      landingzone  = "examples"
    }
  }
}
