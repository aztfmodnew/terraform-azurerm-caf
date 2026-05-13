global_settings = {
  default_region = "region1"
  regions = {
    region1 = "uksouth"
  }
}

resource_groups = {
  postgresql_region1 = {
    name   = "postgresql-region1"
    region = "region1"
  }
  security_region1 = {
    name = "security-region1"
  }
}

# Managed Service Identity (MSI) used to demonstrate db_permissions
managed_identities = {
  app_msi = {
    name               = "app-msi"
    resource_group_key = "postgresql_region1"
  }
}

postgresql_flexible_servers = {
  primary_region1 = {
    name       = "primary-region1"
    region     = "region1"
    version    = "14"
    sku_name   = "GP_Standard_D2s_v3"
    zone       = 1
    storage_mb = 32768

    resource_group = {
      key = "postgresql_region1"
    }

    # Auto-generated administrator credentials stored in azure keyvault when not set (recommended).
    # administrator_username = "pgadmin"
    keyvault = {
      key = "postgresql_region1"
    }

    postgresql_firewall_rules = {
      allow-azure-internal = {
        name             = "allow-azure-internal"
        start_ip_address = "0.0.0.0"
        end_ip_address   = "0.0.0.0"
      }
    }

    postgresql_databases = {
      appdb = {
        name = "appdb"
      }
    }

    # [Optional] Create local database users with passwords stored in Key Vault.
    # This will create a user in the database with the given role.
    # The password is auto-generated and stored in the Key Vault under the secret:
    #   "<server_name>-<database>-<key>-password"
    postgresql_users = {
      app_reader = {
        name     = "appreader"
        role     = "pg_read_all_data"
        database = "appdb"
      }
      app_writer = {
        name     = "appwriter"
        role     = "pg_write_all_data"
        database = "appdb"
      }
    }

    # [Optional] Grant database roles to Managed Identities or AAD groups.
    # The MSI/group must first be created as a role in the database, then granted the specified db_roles.
    # db_usernames are resolved from the remote managed identity name (or AAD group display_name).
    db_permissions = {
      app_msi_permissions = {
        database = "appdb"
        db_roles = ["pg_read_all_data", "pg_write_all_data"]
        managed_identities = {
          lz_key = "" # leave empty to use the current landing zone
          keys   = ["app_msi"]
        }
      }
    }

  }
}

# Store administrator credentials into Key Vault.
keyvaults = {
  postgresql_region1 = {
    name                = "akv"
    resource_group_key  = "security_region1"
    sku_name            = "standard"
    soft_delete_enabled = true
    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge"]
      }
    }
  }
}
