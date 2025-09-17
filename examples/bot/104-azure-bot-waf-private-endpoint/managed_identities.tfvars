# Managed Identity Configuration for Application Gateway to access Key Vault
managed_identities = {
  appgw_keyvault_access = {
    name               = "appgw-keyvault-access"
    resource_group_key = "networking_rg"

    tags = {
      architecture = "secure-bot"
      environment  = "production"
      cost_center  = "it-security"
      service      = "managed-identity"
      purpose      = "application-gateway-keyvault-access"
      example      = "azure-bot-waf-private-endpoint"
      landingzone  = "examples"
    }
  }
}
