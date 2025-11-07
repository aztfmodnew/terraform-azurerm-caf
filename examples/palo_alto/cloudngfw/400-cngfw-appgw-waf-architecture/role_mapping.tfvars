# Role Assignment: Grant Application Gateway identity access to Key Vault certificates
# Required permission: "Key Vault Secrets User" to read certificate secrets
role_mapping = {
  built_in_role_mapping = {
    # Resource Group level: Grant logged in user Key Vault Administrator for certificate management
    resource_groups = {
      networking_rg = {
        "Key Vault Administrator" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
    }
    keyvaults = {
      appgw_certificates = {
        # Allow the Application Gateway managed identity to resolve certificate metadata
        "Key Vault Certificate User" = {
          managed_identities = {
            keys = ["appgw_keyvault_identity"]
          }
        }
        # Allow the Application Gateway managed identity to read the secret version of the cert
        "Key Vault Secrets User" = {
          managed_identities = {
            keys = ["appgw_keyvault_identity"]
          }
        }
      }
    }
  }
}
