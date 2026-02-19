global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  chaos_rg = {
    name = "chaos-storage-nsg-test-1"
  }
}

managed_identities = {
  chaos_identity = {
    name = "chaos-storage-nsg-identity"
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

# Create virtual network with NSG
vnets = {
  test_vnet = {
    resource_group_key = "chaos_rg"
    vnet = {
      name          = "chaos-test-vnet"
      address_space = ["10.0.0.0/16"]
    }
  }
}

virtual_subnets = {
  test_subnet = {
    name    = "storage-subnet"
    cidr    = ["10.0.1.0/24"]
    nsg_key = "storage_nsg"
    vnet = {
      key = "test_vnet"
    }
  }
}

# Network Security Group to be manipulated by Chaos Studio
network_security_groups = {
  storage_nsg = {
    name               = "storage-chaos-nsg"
    resource_group_key = "chaos_rg"

    # Initial allow rule for storage access
    nsg_rules = {
      allow_storage = {
        name                       = "AllowStorageAccess"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["443"]
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "Storage"
      }
    }
  }
}

# Create a test storage account with private endpoint
storage_accounts = {
  test_storage = {
    name                     = "chaosstnsg01"
    resource_group_key       = "chaos_rg"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"

    # Enable network rules
    network_rules = {
      default_action = "Deny"
      bypass         = ["AzureServices"]

      virtual_network_subnet_ids_keys = ["test_subnet"]
    }

    tags = {
      environment = "test"
      purpose     = "chaos-nsg-testing"
    }
  }
}

chaos_studio = {
  # Step 1: Enable chaos on the NSG (Target)
  chaos_studio_targets = {
    nsg_target = {
      resource_group = {
        key = "chaos_rg"
      }

      # Use key-based reference to NSG created above
      target_resource = {
        key = "storage_nsg"
      }
      target_type = "Microsoft-NetworkSecurityGroup"

      tags = {
        environment = "test"
        purpose     = "chaos-nsg-testing"
      }
    }
  }

  # Step 2: Enable SecurityRule capability
  chaos_studio_capabilities = {
    security_rule_capability = {
      capability_type = "SecurityRule-1.0" # NSG Security Rule manipulation

      # Use key-based reference to target created above
      chaos_studio_target = {
        key = "nsg_target"
      }
    }
  }

  # Step 3: Create experiment to block storage access
  chaos_studio_experiments = {
    storage_block_experiment = {
      name = "storage-nsg-block-experiment"
      resource_group = {
        key = "chaos_rg"
      }

      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["chaos_identity"]
      }

      selectors = [
        {
          name = "NSGSelector"
          chaos_studio_targets = [
            {
              key = "nsg_target"
            }
          ]
        }
      ]

      steps = [
        {
          name = "BlockStorageStep"
          branch = [
            {
              name = "BlockBranch"
              actions = [
                {
                  action_type   = "continuous"
                  duration      = "PT5M"
                  selector_name = "NSGSelector"
                  capability = {
                    key = "security_rule_capability"
                  }
                  parameters = [
                    {
                      key   = "name"
                      value = "Block_Storage_Access"
                    },
                    {
                      key   = "protocol"
                      value = "Tcp"
                    },
                    {
                      key   = "sourceAddresses"
                      value = "[\"10.0.1.0/24\"]"
                    },
                    {
                      key   = "destinationAddresses"
                      value = "[\"Storage\"]"
                    },
                    {
                      key   = "access"
                      value = "Deny"
                    },
                    {
                      key   = "destinationPortRanges"
                      value = "[\"443\"]"
                    },
                    {
                      key   = "sourcePortRanges"
                      value = "[\"*\"]"
                    },
                    {
                      key   = "priority"
                      value = "90"
                    },
                    {
                      key   = "direction"
                      value = "Outbound"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]

      tags = {
        environment = "test"
        experiment  = "network-disruption"
      }
    }
  }
}
