global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  chaos_rg = {
    name = "chaos-studio-complete-1"
  }
}

# Create a test storage account to use as chaos target
storage_accounts = {
  test_storage = {
    name                     = "chaostestcomplete01"
    resource_group_key       = "chaos_rg"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

# Managed identity for the experiment
managed_identities = {
  chaos_identity = {
    name               = "chaos-experiment-identity"
    resource_group_key = "chaos_rg"
  }
}

chaos_studio = {
  # Step 1: Enable chaos on the storage account (Target)
  chaos_studio_targets = {
    storage_target = {
      resource_group = {
        key = "chaos_rg"
      }
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

  # Step 2: Enable specific fault capability on the target (Capability)
  chaos_studio_capabilities = {
    stop_capability = {
      capability_type = "StopService-1.0"
      chaos_studio_target = {
        key = "storage_target"
      }
    }
  }

  # Step 3: Create experiment to execute chaos tests (Experiment)
  chaos_studio_experiments = {
    storage_stop_experiment = {
      name = "storage-stop-test"
      resource_group = {
        key = "chaos_rg"
      }

      identity = {
        type = "SystemAssigned"
      }

      selectors = [
        {
          name = "StorageSelector"
          chaos_studio_targets = [
            {
              key = "storage_target"
            }
          ]
        }
      ]

      steps = [
        {
          name = "Stop Storage Service"
          branch = [
            {
              name = "Main Branch"
              actions = [
                {
                  action_type   = "continuous"
                  duration      = "PT5M" # 5 minutes
                  selector_name = "StorageSelector"
                  capability = {
                    key = "stop_capability"
                  }
                  parameters = {
                    virtualMachineScaleSetInstances = "0"
                  }
                }
              ]
            }
          ]
        }
      ]

      tags = {
        environment = "test"
        purpose     = "chaos-experiment"
      }
    }
  }
}
