# RBAC role assignments for Key Vault access
# This provides more granular and secure access control than traditional access policies

role_mapping = {
  built_in_role_mapping = {
    keyvaults = {
      cdn_kv = {
        # Current user/service principal needs full access to manage certificates
        "Key Vault Administrator" = {
          logged_in = {
            keys = ["user"]
          }
        }
        # Managed identity needs access to certificates and secrets for CDN Front Door
        "Key Vault Certificate User" = {
          managed_identities = {
            keys = ["cdn_identity"]
          }
        }
        "Key Vault Secrets User" = {
          managed_identities = {
            keys = ["cdn_identity"]
          }
          # NOTE: Microsoft.AzureFrontDoor-Cdn service principal is automatically
          # granted access by Azure when Front Door uses managed identity.
          # No manual configuration needed.
        }
      }
    }
  }
}
