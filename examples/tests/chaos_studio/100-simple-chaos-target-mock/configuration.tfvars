# Mock Test Configuration for Chaos Studio
# This configuration uses direct IDs for mock testing with Terraform test framework
# Includes tests for: Cosmos DB Failover and NSG Security Rule

global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
    region2 = "northeurope"
  }
  random_length = 5
}

resource_groups = {
  chaos_rg = {
    name = "chaos-studio-test-1"
  }
}

# Cosmos DB configuration for mock test
cosmos_dbs = {
  test_cosmosdb = {
    name                      = "chaostestcosmos"
    resource_group_key        = "chaos_rg"
    offer_type                = "Standard"
    kind                      = "GlobalDocumentDB"
    enable_automatic_failover = true

    consistency_policy = {
      consistency_level       = "Session"
      max_interval_in_seconds = 5
      max_staleness_prefix    = 100
    }

    geo_locations = {
      primary = {
        location          = "region1"
        failover_priority = 0
      }
      secondary = {
        location          = "region2"
        failover_priority = 1
      }
    }
  }
}

# NSG configuration for mock test
network_security_groups = {
  storage_nsg = {
    name               = "storage-chaos-nsg"
    resource_group_key = "chaos_rg"
  }
}

chaos_studio = {
  # Test 1: Cosmos DB Failover Target
  chaos_studio_targets = {
    cosmosdb_target = {
      resource_group = {
        key = "chaos_rg"
      }

      # For mock tests: Use direct resource ID
      target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.DocumentDB/databaseAccounts/chaostestcosmos"
      target_type        = "Microsoft-CosmosDB"

      tags = {
        environment = "test"
        purpose     = "chaos-cosmosdb-mock"
      }
    }

    # Test 2: NSG Security Rule Target
    nsg_target = {
      resource_group = {
        key = "chaos_rg"
      }

      # For mock tests: Use direct resource ID
      target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/networkSecurityGroups/storage-chaos-nsg"
      target_type        = "Microsoft-NetworkSecurityGroup"

      tags = {
        environment = "test"
        purpose     = "chaos-nsg-mock"
      }
    }
  }

  # Capabilities for both tests
  chaos_studio_capabilities = {
    # Cosmos DB Failover capability
    cosmosdb_failover_capability = {
      capability_type = "Failover-1.0"

      # For mock tests: Use direct target ID
      chaos_studio_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Chaos/targets/Microsoft-CosmosDB"
    }

    # NSG Security Rule capability
    nsg_security_rule_capability = {
      capability_type = "SecurityRule-1.0"

      # For mock tests: Use direct target ID
      chaos_studio_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Chaos/targets/Microsoft-NetworkSecurityGroup"
    }
  }
}
