# RBAC role assignments for Key Vault access
# This provides more granular and secure access control than traditional access policies

role_mapping = {
  built_in_role_mapping = {
    keyvaults = {
      bot_certificates_kv = {
        # Current user/service principal needs full access to manage certificates
        "Key Vault Administrator" = {
          logged_in = {
            keys = ["user"]
          }
        }
        # Managed identity needs access to certificates for Application Gateway
        "Key Vault Certificate User" = {
          managed_identities = {
            keys = ["appgw_keyvault_access"]
          }
        }
        # Managed identity needs access to secrets for Application Gateway
        "Key Vault Secrets User" = {
          managed_identities = {
            keys = ["appgw_keyvault_access"]
          }
        }
      }
    }
  }
}
