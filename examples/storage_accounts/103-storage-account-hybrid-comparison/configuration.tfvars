# Storage Account Hybrid Naming Comparison
# This example demonstrates all three naming methods in one configuration
# Shows how different naming methods can be used for different resources

global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "acme"
  suffix         = "v1"
  
  regions = {
    region1 = "eastus"
  }
  
  inherit_tags = true
  
  # Default naming configuration (azurecaf)
  naming = {
    use_azurecaf      = true
    use_local_module  = false
    component_order   = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
  }
}

provider_azurerm_features_keyvault = {
  purge_soft_delete_on_destroy = false
}

resource_groups = {
  test = {
    name = "test"
  }
}

storage_accounts = {
  # Example 1: Using azurecaf naming (default)
  # Expected name: acme-st-webapp-prod-v1
  webapp_storage = {
    name                     = "webapp"
    resource_group_key       = "test"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    
    tags = {
      naming_method = "azurecaf"
      purpose       = "web-application-storage"
    }
    
    containers = {
      static = {
        name = "static-content"
      }
    }
  }
  
  # Example 2: Using local module naming with custom order
  # Expected name: acme-st-analytics-prod-eus-001-v1
  analytics_storage = {
    name                     = "analytics"
    resource_group_key       = "test"
    account_kind             = "StorageV2"
    account_tier             = "Premium"
    account_replication_type = "LRS"
    
    # Override naming method for this specific resource
    naming = {
      use_local_module = true
      component_order  = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]
    }
    
    instance = "001"
    
    tags = {
      naming_method = "local_module"
      purpose       = "analytics-data-storage"
    }
    
    containers = {
      raw = {
        name = "raw-data"
      }
      processed = {
        name = "processed-data"
      }
    }
  }
  
  # Example 3: Using passthrough naming (exact name)
  # Expected name: legacystorage2024prod
  legacy_storage = {
    name                     = "legacystorage2024prod"
    resource_group_key       = "test"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "GRS"
    
    # Override naming method for this specific resource
    naming = {
      passthrough = true
    }
    
    tags = {
      naming_method = "passthrough"
      purpose       = "legacy-system-storage"
      note          = "Using exact name for legacy compatibility"
    }
    
    containers = {
      legacy = {
        name = "legacy-files"
      }
    }
  }
}
