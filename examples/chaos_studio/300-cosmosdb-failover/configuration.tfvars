global_settings = {
  default_region = "region1"
  regions = {
    region1 = "northeurope"
    region2 = "australiacentral"
  }
  random_length = 5
}

resource_groups = {
  chaos_rg = {
    name = "chaos-cosmosdb-test-1"
  }
}

managed_identities = {
  chaos_identity = {
    name = "chaos-cosmosdb-identity"
    resource_group = {
      key = "chaos_rg"
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    resource_groups = {
      chaos_rg = {
        "Contributor" = {
          managed_identities = {
            keys = ["chaos_identity"]
          }
        }
      }
    }
  }
}

# Create a Cosmos DB account with multi-region replication
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
        region            = "region1"
        failover_priority = 0
        zone_redundant    = false # Disable zone redundancy to avoid capacity issues
      }
      secondary = {
        region            = "region2"
        failover_priority = 1
        zone_redundant    = false # Disable zone redundancy to avoid capacity issues
      }
    }

    tags = {
      environment = "test"
      purpose     = "chaos-failover"
    }
  }
}

chaos_studio = {
  # Step 1: Enable chaos on the Cosmos DB account (Target)
  chaos_studio_targets = {
    cosmosdb_target = {
      resource_group = {
        key = "chaos_rg"
      }

      # Use key-based reference to Cosmos DB created above
      target_resource = {
        key = "test_cosmosdb"
      }
      target_type = "Microsoft-CosmosDB"

      tags = {
        environment = "test"
        purpose     = "chaos-failover-testing"
      }
    }
  }

  # Step 2: Enable failover capability
  chaos_studio_capabilities = {
    failover_capability = {
      capability_type = "Failover-1.0" # Valid for Cosmos DB

      # Use key-based reference to target created above
      chaos_studio_target = {
        key = "cosmosdb_target"
      }
    }
  }

  # Step 3: Create failover experiment
  chaos_studio_experiments = {
    cosmosdb_failover_experiment = {
      name = "cosmosdb-failover-experiment"
      resource_group = {
        key = "chaos_rg"
      }

      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["chaos_identity"]
      }

      selectors = [
        {
          name = "CosmosSelector"
          chaos_studio_targets = [
            {
              key = "cosmosdb_target"
            }
          ]
        }
      ]

      steps = [
        {
          name = "FailoverStep"
          branch = [
            {
              name = "FailoverBranch"
              actions = [
                {
                  action_type   = "continuous"
                  duration      = "PT10M"
                  selector_name = "CosmosSelector"
                  capability = {
                    key = "failover_capability"
                  }
                  parameters = {
                    readRegion = "Australia Central" # Secondary region for failover
                  }
                }
              ]
            }
          ]
        }
      ]

      tags = {
        environment = "test"
        experiment  = "failover"
      }
    }
  }
}
