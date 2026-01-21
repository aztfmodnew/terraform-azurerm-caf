# Mock Test Configuration for Chaos Studio
# This configuration uses direct IDs for mock testing with Terraform test framework
# For real deployments, use the 100-simple-chaos-target example with key-based references

global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  chaos_rg = {
    name = "chaos-studio-test-1"
  }
}

# Storage account configuration (will be created but not used for references in mock)
storage_accounts = {
  test_storage = {
    name                     = "chaostestst01"
    resource_group_key       = "chaos_rg"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

chaos_studio = {
  # Step 1: Enable chaos on the storage account (Target)
  chaos_studio_targets = {
    storage_target = {
      resource_group = {
        key = "chaos_rg"
      }
      
      # For mock tests: Use direct resource ID
      # This allows the test to pass without requiring resources to be created first
      target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/chaostestst01"
      target_type        = "Microsoft-StorageAccount"
      
      tags = {
        environment = "test"
        purpose     = "chaos-testing-mock"
      }
    }
  }

  # Step 2: Enable fault capability (makes it visible in Chaos Studio)
  chaos_studio_capabilities = {
    failover_capability = {
      capability_type = "Failover-1.0" # Valid for Storage Account
      
      # For mock tests: Use direct target ID
      chaos_studio_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Chaos/targets/Microsoft-StorageAccount"
    }
  }
}
