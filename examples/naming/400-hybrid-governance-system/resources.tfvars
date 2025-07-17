# Hybrid Governance Examples
# Shows different scenarios: global control, resource patterns, and individual overrides

# 📋 Scenario 1: Global Configuration Applied
# Uses global settings: prefix="org", separator="-", environment="prod"
container_app_environments = {
  global_pattern = {
    name               = "webapp"
    resource_group_key = "example_rg"
    # No naming override - uses global + resource pattern
    # Result: cae_webapp_prod_001 (uses resource pattern for azurerm_container_app_environment)
  }
}

# 📋 Scenario 2: Resource Pattern Override
# Uses resource-specific pattern from global_settings.naming.resource_patterns
storage_accounts = {
  resource_pattern = {
    name               = "documents"
    resource_group_key = "example_rg"
    # Uses resource pattern: separator="", no suffix
    # Result: orgdocumentsprod001 (storage account specific pattern)
  }
}

# 📋 Scenario 3: Individual Resource Override
# Demonstrates individual control when allow_resource_override = true
container_app_environments = {
  individual_override = {
    name               = "customapp"
    resource_group_key = "example_rg"
    instance           = "dev001"
    
    # 🔧 Individual naming override
    naming = {
      prefix          = "team"      # Override global prefix
      separator       = "-"         # Override resource pattern separator
      environment     = "develop"   # Override global environment
      component_order = ["prefix", "name", "environment", "instance"]
      suffix          = "special"   # Add custom suffix
    }
    # Result: team-customapp-develop-dev001-special
  }
}

# 📋 Scenario 4: Mixed Overrides
# Shows partial override with fallback to global/resource patterns
key_vaults = {
  mixed_override = {
    name               = "secrets"
    resource_group_key = "example_rg"
    
    # 🎨 Partial override - only separator and prefix
    naming = {
      separator = "_"        # Override resource pattern separator
      prefix    = "secure"   # Override resource pattern prefix
      # environment, region, suffix fall back to resource pattern/global
    }
    # Result: secure_secrets_prod_westeurope_kv
  }
}

# 📋 Scenario 5: Controlled Mode Simulation
# Shows what happens when allow_resource_override = false
# (These would ignore naming overrides if governance is strict)
storage_accounts = {
  strict_governance = {
    name               = "controlled"
    resource_group_key = "example_rg"
    
    # ⚠️ This naming block would be ignored if allow_resource_override = false
    naming = {
      prefix = "unauthorized"  # Would be ignored in strict mode
      suffix = "blocked"       # Would be ignored in strict mode
    }
    # Result: orgcontrolledprod001 (follows resource pattern only)
  }
}

# Supporting resource group
resource_groups = {
  example_rg = {
    name = "hybrid-naming-example"
  }
}
