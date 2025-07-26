# Naming Method Comparison - Same Resources with Different Naming Methods
# Demonstrates local_module, azurecaf, and passthrough methods

# Method 1: Local Module Naming (default from global_settings)
storage_accounts = {
  local_module_example = {
    name                     = "localmodule"
    resource_group_key       = "comparison"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    instance                 = "001"
    # Result: complocalmoduletest001 (local module pattern)
    # Method: local_module
  }
  # Method 4: Compare different local module configurations
  custom_pattern = {
    name                     = "custompattern"
    resource_group_key       = "comparison"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    instance                 = "002"

    # Custom local module configuration
    naming = {
      separator       = "_"
      component_order = ["name", "environment", "instance", "prefix"]
      prefix          = "custom"
    }
    # Result: custompattern_test_002_custom (custom pattern)
    # Method: local_module (customized)
  }
  # Method 5: Global pattern vs resource pattern comparison
  global_pattern = {
    name                     = "globalpattern"
    resource_group_key       = "comparison"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    instance                 = "003"
    # Uses global configuration
    # Result: compglobalpatterntest003 (no separators from resource pattern)
  }
}

# Method 2: Force azurecaf naming for this specific resource
container_app_environments = {
  azurecaf_example = {
    name               = "azurecaf"
    resource_group_key = "comparison"
    instance           = "001"

    # Override to force azurecaf method
    naming = {
      use_azurecaf     = true
      use_local_module = false
    }
    # Result: Will use azurecaf provider naming
    # Method: azurecaf
  }
  # Method 6: Demonstrate fallback behavior
  fallback_example = {
    name               = "fallback"
    resource_group_key = "comparison"

    # Disable all naming methods to trigger fallback
    naming = {
      use_azurecaf     = false
      use_local_module = false
      passthrough      = false
    }
    # Result: fallback (original name, fallback method)
    # Method: fallback
  }
}

# Method 3: Passthrough naming (exact name specified)
key_vaults = {
  passthrough_example = {
    name               = "passthroughexample"
    resource_group_key = "comparison"

    # Override to force passthrough method
    naming = {
      passthrough = true
    }
    # Result: passthroughexample (exact name, no modifications)
    # Method: passthrough
  }
}







resource_groups = {
  comparison = {
    name = "comparison-rg"
  }
}
