# Managed Identity for Application Gateway
# Following Azure Best Practices:
# - User-assigned managed identity for accessing Key Vault
# - RBAC assignments for Key Vault certificate access

managed_identities = {
  appgw_keyvault_identity = {
    name               = "appgw-kv-identity"
    resource_group_key = "networking_rg"

    tags = {
      purpose = "application-gateway-keyvault-access"
    }
  }
}

