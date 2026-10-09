mock_provider "azurerm" {
  mock_resource "azurerm_machine_learning_workspace" {
    override_during = plan
    defaults = {
      id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/aml-test"
      workspace_id  = "00000000-0000-0000-0000-000000000001"
      discovery_url = "https://region.api.azureml.ms/discovery"
    }
  }
}

variables {
  global_settings = {
    prefixes      = []
    suffixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
    inherit_tags  = true
    tags          = { environment = "test" }
  }
  client_config = { landingzone_key = "local" }
  resource_groups = {
    local = {
      test_rg = {
        name     = "test-rg"
        location = "australiaeast"
        tags     = { cost_center = "analytics" }
      }
    }
  }
  base_tags = {
    environment = "test"
    cost_center = "analytics"
    inherited   = "yes"
  }
  keyvault_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  storage_account_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
  application_insights_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/test-ai"
  container_registry_id   = null
  vnets = {
    local = {
      test_vnet = {
        subnets = {
          pe = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/pe"
          }
        }
      }
    }
  }
  diagnostics = {
    diagnostics_definition   = {}
    diagnostics_destinations = {}
    storage_accounts         = {}
    log_analytics            = {}
    event_hub_namespaces     = {}
  }
  private_endpoints = {}
  private_dns       = {}
  remote_objects = {
    managed_identities = {
      local = {
        aml_identity = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aml"
        }
      }
      remote = {
        shared_identity = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/shared-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/shared"
        }
      }
    }
  }
}

run "all_workspace_options_and_child_resources_are_supported" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning"
  }

  variables {
    global_settings         = var.global_settings
    client_config           = var.client_config
    resource_groups         = var.resource_groups
    base_tags               = var.base_tags
    keyvault_id             = var.keyvault_id
    storage_account_id      = var.storage_account_id
    application_insights_id = var.application_insights_id
    container_registry_id   = var.container_registry_id
    vnets                   = var.vnets
    diagnostics = {
      diagnostics_definition = {
        aml_workspace = {
          name = "aml-workspace-diagnostics"
          categories = {
            log    = []
            metric = [["AllMetrics", true, false, 0]]
          }
        }
      }
      diagnostics_destinations = {
        log_analytics = {
          central = {
            log_analytics_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring-rg/providers/Microsoft.OperationalInsights/workspaces/central"
          }
        }
      }
      storage_accounts     = {}
      log_analytics        = {}
      event_hub_namespaces = {}
    }
    private_endpoints = {
      workspace = {
        name               = "aml-workspace"
        resource_group_key = "test_rg"
        vnet_key           = "test_vnet"
        subnet_key         = "pe"
        private_service_connection = {
          name              = "aml-workspace"
          subresource_names = ["amlworkspace"]
        }
        private_dns = {
          keys = ["aml_api"]
        }
      }
    }
    private_dns = {
      local = {
        aml_api = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.api.azureml.ms"
        }
      }
    }
    remote_objects = var.remote_objects
    settings = {
      name                            = "aml-test"
      resource_group_key              = "test_rg"
      sku_name                        = "Basic"
      kind                            = "FeatureStore"
      description                     = "Workspace contract"
      friendly_name                   = "AML contract"
      high_business_impact            = true
      public_network_access_enabled   = false
      image_build_compute_name        = "image-builder"
      primary_user_assigned_identity  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aml"
      v1_legacy_mode_enabled          = true
      storage_account_access_type     = "Identity"
      service_side_encryption_enabled = true
      identity = {
        type                  = "SystemAssigned, UserAssigned"
        managed_identity_keys = ["aml_identity"]
        remote = {
          remote = {
            managed_identity_keys = ["shared_identity"]
          }
        }
      }
      encryption = {
        key_vault_id              = var.keyvault_id
        key_id                    = "https://test-kv.vault.azure.net/keys/aml"
        user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aml"
      }
      managed_network = {
        isolation_mode                = "AllowOnlyApprovedOutbound"
        provision_on_creation_enabled = true
      }
      feature_store = {
        computer_spark_runtime_version = "3.4"
        offline_connection_name        = "offline"
        online_connection_name         = "online"
      }
      serverless_compute = {
        subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/serverless"
        public_ip_enabled = false
      }
      network_outbound_rules = {
        fqdn = {
          package_feed = {
            destination_fqdn = "packages.example.com"
            timeouts = {
              create = "35m"
              read   = "7m"
              update = "35m"
              delete = "35m"
            }
          }
        }
        private_endpoint = {
          storage_blob = {
            service_resource_id = var.storage_account_id
            sub_resource_target = "blob"
            spark_enabled       = true
            timeouts = {
              create = "35m"
              read   = "7m"
              delete = "35m"
            }
          }
        }
        service_tag = {
          storage = {
            service_tag = "Storage"
            protocol    = "TCP"
            port_ranges = "443"
          }
        }
      }
      diagnostic_profiles = {
        workspace_logs = {
          definition_key   = "aml_workspace"
          destination_type = "log_analytics"
          destination_key  = "central"
        }
      }
      tags = { owner = "analytics" }
      timeouts = {
        create = "40m"
        read   = "8m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition = (
      azurerm_machine_learning_workspace.ws.kind == "FeatureStore" &&
      azurerm_machine_learning_workspace.ws.sku_name == "Basic" &&
      azurerm_machine_learning_workspace.ws.public_network_access_enabled == false &&
      azurerm_machine_learning_workspace.ws.image_build_compute_name == "image-builder" &&
      azurerm_machine_learning_workspace.ws.primary_user_assigned_identity != null &&
      azurerm_machine_learning_workspace.ws.v1_legacy_mode_enabled &&
      azurerm_machine_learning_workspace.ws.storage_account_access_type == "Identity" &&
      azurerm_machine_learning_workspace.ws.service_side_encryption_enabled &&
      azurerm_machine_learning_workspace.ws.identity[0].type == "SystemAssigned, UserAssigned" &&
      length(azurerm_machine_learning_workspace.ws.identity[0].identity_ids) == 2 &&
      azurerm_machine_learning_workspace.ws.encryption[0].key_id == "https://test-kv.vault.azure.net/keys/aml" &&
      azurerm_machine_learning_workspace.ws.managed_network[0].isolation_mode == "AllowOnlyApprovedOutbound" &&
      azurerm_machine_learning_workspace.ws.feature_store[0].offline_connection_name == "offline" &&
      azurerm_machine_learning_workspace.ws.serverless_compute[0].public_ip_enabled == false &&
      azurerm_machine_learning_workspace.ws.tags.owner == "analytics" &&
      azurerm_machine_learning_workspace.ws.tags.cost_center == "analytics"
    )
    error_message = "The workspace must expose provider options, nested blocks, CAF identities, and merged tags."
  }

  assert {
    condition = (
      azurerm_machine_learning_workspace_network_outbound_rule_fqdn.rules["package_feed"].destination_fqdn == "packages.example.com" &&
      azurerm_machine_learning_workspace_network_outbound_rule_private_endpoint.rules["storage_blob"].sub_resource_target == "blob" &&
      azurerm_machine_learning_workspace_network_outbound_rule_service_tag.rules["storage"].port_ranges == "443" &&
      output.id == azurerm_machine_learning_workspace.ws.id &&
      output.workspace_id == azurerm_machine_learning_workspace.ws.workspace_id &&
      output.discovery_url == azurerm_machine_learning_workspace.ws.discovery_url
    )
    error_message = "The module must create each managed-network rule type and expose the workspace outputs."
  }
}

run "provider_defaults_and_system_identity_are_preserved" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning"
  }

  variables {
    global_settings         = var.global_settings
    client_config           = var.client_config
    resource_groups         = var.resource_groups
    base_tags               = var.base_tags
    keyvault_id             = var.keyvault_id
    storage_account_id      = var.storage_account_id
    application_insights_id = var.application_insights_id
    container_registry_id   = null
    vnets                   = var.vnets
    diagnostics             = var.diagnostics
    private_endpoints       = {}
    private_dns             = {}
    remote_objects          = {}
    settings = {
      name               = "aml-defaults"
      resource_group_key = "test_rg"
    }
  }

  assert {
    condition = (
      azurerm_machine_learning_workspace.ws.public_network_access_enabled &&
      azurerm_machine_learning_workspace.ws.identity[0].type == "SystemAssigned" &&
      azurerm_machine_learning_workspace.ws.tags.environment == "test" &&
      azurerm_machine_learning_workspace.ws.tags.inherited == "yes"
    )
    error_message = "Omitted optional workspace settings must retain the public-access, system identity, and CAF tag defaults."
  }
}
