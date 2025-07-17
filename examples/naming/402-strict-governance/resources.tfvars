# Strict Governance - All Resources Follow Organizational Patterns
# No individual overrides allowed - ensures complete consistency

# Example 1: Storage account follows mandatory pattern
storage_accounts = {
  corporate_data = {
    name               = "data"
    resource_group_key = "storage"
    account_tier       = "Standard"
    account_replication_type = "LRS"
    instance           = "001"
    # Result: corpstdataprod001 (no separators, enforced pattern)
  }
  
  backup_storage = {
    name               = "backup"
    resource_group_key = "storage" 
    account_tier       = "Standard"
    account_replication_type = "GRS"
    instance           = "002"
    # Result: corpstbackupprod002
  }
}

# Example 2: Key vault follows organizational standard
key_vaults = {
  main_vault = {
    name                = "secrets"
    resource_group_key  = "security"
    # Result: corp-kv-secrets-prod-westeurope (enforced pattern)
  }
  
  app_vault = {
    name                = "appsecrets"
    resource_group_key  = "security"
    # Result: corp-kv-appsecrets-prod-westeurope
  }
}

# Example 3: Container app environment follows corporate pattern
container_app_environments = {
  production_env = {
    name                = "webapp"
    resource_group_key  = "compute"
    instance            = "001"
    # Result: corp-cae-webapp-prod-001-001 (enforced pattern)
  }
  
  api_env = {
    name                = "api"
    resource_group_key  = "compute"
    instance            = "002"
    # Result: corp-cae-api-prod-002-001
  }
}

# Example 4: Any attempt to override naming will be IGNORED
storage_accounts = {
  ignored_override = {
    name               = "logs"
    resource_group_key = "monitoring"
    account_tier       = "Standard"
    account_replication_type = "LRS"
    instance           = "003"
    
    # This naming block will be IGNORED in strict mode
    naming = {
      prefix    = "team1"       # ❌ Ignored
      separator = "_"           # ❌ Ignored  
      suffix    = "custom"      # ❌ Ignored
    }
    # Result: corpstlogsprod003 (follows enforced pattern)
  }
}

resource_groups = {
  storage = {
    name = "storage-rg"
  }
  security = {
    name = "security-rg"
  }
  compute = {
    name = "compute-rg"
  }
  monitoring = {
    name = "monitoring-rg"
  }
}
