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
managed_identities = {
  chaos_identity = {
    name = "chaos-experiment-identity"
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
# Create a test storage account to use as target
# NOTE: Failover capability requires geo-redundant storage (GRS, RA-GRS, GZRS, or RA-GZRS)
storage_accounts = {
  test_storage = {
    name                     = "chaostestst01"
    resource_group_key       = "chaos_rg"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "GRS" # Changed from LRS to support failover
  }
}

chaos_studio = {
  # Step 1: Enable chaos on the storage account (Target)
  chaos_studio_targets = {
    storage_target = {
      resource_group = {
        key = "chaos_rg"
      }

      # Use key-based reference to storage account created above
      target_resource = {
        key = "test_storage"
      }
      target_type = "Microsoft-StorageAccount"

      tags = {
        environment = "test"
        purpose     = "chaos-testing"
      }
    }
  }

  # Step 2: Enable fault capability (makes it visible in Chaos Studio)
  chaos_studio_capabilities = {
    failover_capability = {
      capability_type = "Failover-1.0" # Valid for Storage Account

      # Use key-based reference to target created above
      chaos_studio_target = {
        key = "storage_target"
      }
    }
  }

  chaos_studio_experiments = {
    storage_failover_experiment = {
      name = "storage-failover-experiment"
      resource_group = {
        key = "chaos_rg"
      }

      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["chaos_identity"]
      }

      selectors = [
        {
          name = "Selector1"
          chaos_studio_targets = [
            {
              key = "storage_target"
            }
          ]
        }
      ]

      steps = [
        {
          name = "Step1"
          branch = [
            {
              name = "Branch1"
              actions = [
                {
                  action_type   = "continuous"
                  duration      = "PT10M"
                  selector_name = "Selector1"
                  capability = {
                    key = "failover_capability"
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
