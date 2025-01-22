network_managers = {
  network_manager_1 = {
    name               = "network_manager_1"
    resource_group_key = "test_re1"
    /* subscriptions = [
    {
      lz_key = "lz-key-1"
      key    = "key-1"
    },
    {
      lz_key = "lz-key-2"
      key    = "key-2"
    }
  ]*/
    scope = {
      #"management_group_ids" = ["/providers/Microsoft.Management/managementGroups/00000000-0000-0000-0000-000000000000","/providers/Microsoft.Management/managementGroups/11111111-1111-1111-1111-111111111111"]
      #"subscription_ids" = ["/subscriptions/00000000-0000-0000-0000-000000000000", "/subscriptions/11111111-1111-1111-1111-111111111111"]
      # By default the network manager will be created in the same subscription as the terraform is launched
    }
    scope_accesses = ["Connectivity", "SecurityAdmin", "Routing"]
    description    = "Test Network Manager"
    tags = {
      "environment" = "test"
    }
    network_groups = {
      network_group_1 = {
        name        = "network_group_1"
        description = "Test Network Group"
      }
    }
    static_members = {
      static_member_1 = {
        name = "static_member_1"
        network_group = {
          #lz_key = "lz-key-1"
          key = "network_group_1"
        }
        #network_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/networkManagers/network_manager_1/networkGroups/network_group_1"
        target_virtual_network = {
          #lz_key = "lz-key-1"
          key = "vnet_region1"
        }
        #target_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/virtualNetworks/vnet1"
      }
    }
    admin_rule_collections = {
      admin_rule_collection_1 = {
        name        = "admin_rule_collection_1"
        description = "Test Admin Rule Collection"
        #network_group_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/networkManagers/network_manager_1/networkGroups/network_group_1", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/networkManagers/network_manager_1/networkGroups/network_group_2"]
        network_groups = [
          {
            #lz_key = "lz-key-1
            key = "network_group_1"
          }
        ]
        security_admin_configuration = {
          #lz_key = "lz-key-1
          key = "security_admin_configuration_1"
        }
        description = "Example Admin Rule Collection"
      }
    }
    admin_rules = {
      admin_rule_1 = {
        admin_rule_collection = {
          #lz_key = "lz-key-1"
          key = "admin_rule_collection_1"
        }
        name                    = "admin_rule_1"
        description             = "Test Admin Rule"
        action                  = "Allow"
        direction               = "Outbound"
        priority                = 1
        protocol                = "Tcp"
        source_port_ranges      = ["80", "1024-65535"]
        destination_port_ranges = ["80"]
        source = [
          {
            address_prefix      = "Internet"
            address_prefix_type = "ServiceTag"
          }
        ]
        destination = [
          {
            address_prefix_type = "IPPrefix"
            address_prefix      = "10.1.0.1"
          },
          {
            address_prefix_type = "IPPrefix"
            address_prefix      = "10.0.0.0/24"
          }
        ]
        description = "Example Admin Rule"
      }
    }
    security_admin_configurations = {
      security_admin_configuration_1 = {
        name                                         = "security_admin_configuration_1"
        description                                  = "Test Security Admin Configuration"
        description                                  = "Example Security Admin Configuration"
        appy_on_network_intent_policy_based_services = ["All"]
      }
    }
    deployments = {
      deployment_1 = {
        location     = "australiaeast"
        scope_access = "SecurityAdmin"
        /*configuration_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/networkManagers/network_manager_1/configurations/configuration_1",
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/networkManagers/network_manager_1/configurations/configuration_2"
        ]*/
        security_admin_configurations = [
          {
            #lz_key = "lz-key-1"
            key = "security_admin_configuration_1"
          }
        ]
      }
    }
  }
}


# Standalone Resources, if you want to create them separately because they are used in existing network managers

network_manager_network_groups = {
  network_group_2 = {
    name = "network_group_2"
    #network_manager_id = /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/networkManagers/network_manager_1
    description = "Test Network Group"
    network_manager = {
      #lz_key = "lz-key-1"
      key = "network_manager_1"
    }

  }
}



network_manager_static_members = {
  static_member_2 = {
    name = "static_member_2"
    network_group = {
      #lz_key = "lz-key-1"
      key = "network_group_2"
    }
    target_virtual_network = {
      #lz_key = "lz-key-1"
      key = "vnet_workload_region1"
    }
  }
}

network_manager_connectivity_configurations = {
  connectivity_configuration_1 = {
    name = "connectivity_configuration_1"
    network_manager = {
      #lz_key = "lz-key-1"
      key = "network_manager_1"
    }
    applies_to_groups = [
      {
        group_connectivity = "DirectlyConnected"
        network_group = {
          #lz_key = "lz-key-1"
          key = "network_group_2"
        }
        global_mesh_enabled = false
        use_hub_gateway     = true
      }
    ]
    connectivity_topology           = "HubAndSpoke"
    delete_existing_peering_enabled = false
    description                     = "Test Connectivity Configuration"
    global_mesh_enabled             = false
    hub = {
      vnet = {
        #lz_key = "lz-key-1"
        key = "vnet_hub_region1"
      }
      # resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test_rg/providers/Microsoft.Network/virtualNetworks/vnet_hub_region1"
      resource_type = "Microsoft.Network/virtualNetworks"
    }
  }
}

network_manager_deployments = {
  deployment_2 = {
    location     = "australiaeast"
    scope_access = "Connectivity"
    network_manager = {
      #lz_key = "lz-key-1"
      key = "network_manager_1"
    }
    connectivity_configurations = [
      {
        #lz_key = "lz-key-1"
        key = "connectivity_configuration_1"
      }
    ]
  }
}

