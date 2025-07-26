# Flexible Governance - Resources with Individual Overrides
# Demonstrates how teams can customize naming while respecting organizational patterns

# Example 1: Uses global configuration (org-st-myapp-prod-westeurope-001)
storage_accounts = {
  global_pattern = {
    name                     = "myapp"
    resource_group_key       = "networking"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
  # Example 4: Uses resource pattern (no separator for storage)
  pattern_based = {
    name                     = "logs"
    resource_group_key       = "monitoring"
    account_tier             = "Standard"
    account_replication_type = "GRS"
    # Uses resource pattern: orglogsproduction001 (no separators)
  }
}

# Example 2: Team override for development environment
container_app_environments = {
  dev_override = {
    name               = "devapp"
    resource_group_key = "development"

    # Team-specific naming override
    naming = {
      environment = "dev"
      prefix      = "team1"
      separator   = "_"
      suffix      = "test"
    }
    # Result: team1_cae_devapp_dev_test
  }
}

# Example 3: Project-specific patterns
key_vaults = {
  project_vault = {
    name               = "secrets"
    resource_group_key = "security"

    # Project-specific naming
    naming = {
      prefix          = "proj"
      environment     = "shared"
      component_order = ["prefix", "name", "environment", "region"]
    }
    # Result: proj-secrets-shared-westeurope
  }
}




resource_groups = {
  networking = {
    name = "networking-rg"
  }
  development = {
    name = "development-rg"
  }
  security = {
    name = "security-rg"
  }
  monitoring = {
    name = "monitoring-rg"
  }
}
