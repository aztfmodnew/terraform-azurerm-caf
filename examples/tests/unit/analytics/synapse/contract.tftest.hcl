mock_provider "azurerm" {
  mock_resource "azurerm_synapse_workspace" {
    override_during = plan
    defaults = {
      id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/synapse-contract"
      managed_resource_group_name = "synapse-contract-managed"
      connectivity_endpoints      = { web = "https://synapse-contract.dev.azuresynapse.net" }
      identity = {
        principal_id = "00000000-0000-0000-0000-000000000010"
        tenant_id    = "00000000-0000-0000-0000-000000000011"
        type         = "SystemAssigned, UserAssigned"
      }
    }
  }

  mock_resource "azurerm_synapse_firewall_rule" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/synapse-contract/firewallRules/allow-ci"
    }
  }

  mock_resource "azurerm_synapse_workspace_aad_admin" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/synapse-contract/administrators/activeDirectory"
    }
  }

  mock_resource "azurerm_synapse_spark_pool" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/synapse-contract/bigDataPools/spark-contract"
    }
  }

  mock_resource "azurerm_synapse_sql_pool" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/synapse-contract/sqlPools/sql-contract"
    }
  }

  mock_resource "azurerm_key_vault_secret" {
    defaults = {
      id = "https://test-kv.vault.azure.net/secrets/synapse-contract"
    }
  }
}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "synapse-contract" }
  }
}

mock_provider "random" {
  mock_resource "random_password" {
    defaults = { result = "Mock-Generated-Password-123!" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
    tags          = { environment = "test" }
  }
  client_config = { landingzone_key = "local" }
  resource_group = {
    name     = "test-rg"
    location = "australiaeast"
    tags     = { cost_center = "analytics" }
  }
  resource_group_name                  = "test-rg"
  location                             = "australiaeast"
  base_tags                            = true
  keyvault_id                          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  storage_data_lake_gen2_filesystem_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default/containers/synapse"
  vnets = {
    local = {
      test_vnet = {
        subnets = {
          compute = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/compute"
          }
        }
      }
    }
  }
  remote_objects = {
    managed_identities = {
      local = {
        workspace_identity = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/workspace"
        }
      }
      shared = {
        shared_identity = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/shared-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/shared"
        }
      }
    }
  }
  private_endpoints = {}
  private_dns       = {}
}

run "workspace_provider_options_and_child_resources" {
  command = plan

  module {
    source = "../modules/analytics/synapse"
  }

  variables {
    global_settings                      = var.global_settings
    client_config                        = var.client_config
    resource_group                       = var.resource_group
    resource_group_name                  = var.resource_group_name
    location                             = var.location
    base_tags                            = var.base_tags
    keyvault_id                          = var.keyvault_id
    storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
    vnets                                = var.vnets
    remote_objects                       = var.remote_objects
    private_endpoints                    = var.private_endpoints
    private_dns                          = var.private_dns
    settings = {
      name                        = "synapse-contract"
      sql_administrator_login     = "synapseadmin"
      azuread_authentication_only = true
      compute_subnet = {
        key      = "compute"
        vnet_key = "test_vnet"
      }
      data_exfiltration_protection_enabled = true
      managed_virtual_network_enabled      = true
      public_network_access_enabled        = false
      linking_allowed_for_aad_tenant_ids   = ["00000000-0000-0000-0000-000000000020"]
      purview_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Purview/accounts/test-purview"
      identity = {
        type                  = "SystemAssigned, UserAssigned"
        managed_identity_keys = ["workspace_identity"]
        remote = {
          shared = {
            managed_identity_keys = ["shared_identity"]
          }
        }
      }
      customer_managed_key = {
        key_versionless_id        = "https://test-kv.vault.azure.net/keys/synapse-key"
        key_name                  = "synapse-key"
        user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/workspace"
      }
      github_repo = {
        account_name    = "contoso"
        branch_name     = "main"
        repository_name = "synapse"
        root_folder     = "/"
        git_url         = "https://github.com/contoso/synapse"
      }
      workspace_firewall = {
        name     = "legacy-allow-ci"
        start_ip = "192.0.2.10"
        end_ip   = "192.0.2.10"
        timeouts = {
          create = "30m"
          read   = "5m"
          update = "30m"
          delete = "30m"
        }
      }
      workspace_firewalls = {
        ci = {
          name     = "allow-ci"
          start_ip = "192.0.2.20"
          end_ip   = "192.0.2.20"
          timeouts = {
            create = "30m"
            read   = "5m"
            update = "30m"
            delete = "30m"
          }
        }
      }
      aad_admin = {
        login     = "synapse-admin"
        object_id = "00000000-0000-0000-0000-000000000030"
        tenant_id = "00000000-0000-0000-0000-000000000031"
        timeouts = {
          create = "30m"
          read   = "5m"
          update = "30m"
          delete = "30m"
        }
      }
      timeouts = {
        create = "60m"
        read   = "10m"
        update = "60m"
        delete = "60m"
      }
      key_vault_secret_timeouts = {
        create = "10m"
        read   = "5m"
        update = "10m"
        delete = "10m"
      }
      synapse_spark_pools = {
        spark = {
          name             = "spark-contract"
          node_size_family = "MemoryOptimized"
          node_size        = "XXXLarge"
          spark_version    = "3.5"
          auto_scale = {
            min_node_count = 3
            max_node_count = 20
          }
          auto_pause = {
            delay_in_minutes = 15
          }
          cache_size                          = 100
          compute_isolation_enabled           = true
          dynamic_executor_allocation_enabled = true
          min_executors                       = 2
          max_executors                       = 8
          library_requirement = {
            content  = "requests==2.31.0"
            filename = "requirements.txt"
          }
          session_level_packages_enabled = true
          spark_config = {
            content  = "spark.shuffle.spill true"
            filename = "spark.conf"
          }
          spark_log_folder    = "/custom-logs"
          spark_events_folder = "/custom-events"
          timeouts = {
            create = "45m"
            read   = "7m"
            update = "45m"
            delete = "45m"
          }
        }
      }
      synapse_sql_pools = {
        sql = {
          name                 = "sql-contract"
          sku_name             = "DW500c"
          storage_account_type = "LRS"
          create_mode          = "PointInTimeRestore"
          collation            = "SQL_Latin1_General_CP1_CI_AS"
          data_encrypted       = true
          restore = {
            point_in_time      = "2025-01-01T00:00:00Z"
            source_database_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/source/sqlPools/source"
          }
          geo_backup_policy_enabled = false
          timeouts = {
            create = "45m"
            read   = "7m"
            update = "45m"
            delete = "45m"
          }
        }
      }
      tags = { owner = "analytics" }
    }
  }

  assert {
    condition = (
      azurerm_synapse_workspace.ws.azuread_authentication_only &&
      azurerm_synapse_workspace.ws.compute_subnet_id == var.vnets.local.test_vnet.subnets.compute.id &&
      !azurerm_synapse_workspace.ws.public_network_access_enabled &&
      azurerm_synapse_workspace.ws.purview_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Purview/accounts/test-purview" &&
      toset(azurerm_synapse_workspace.ws.linking_allowed_for_aad_tenant_ids) == toset(["00000000-0000-0000-0000-000000000020"])
    )
    error_message = "Workspace security, networking, tenant-linking, and Purview settings must reach the provider resource."
  }

  assert {
    condition = (
      toset(azurerm_synapse_workspace.ws.identity[0].identity_ids) == toset([
        var.remote_objects.managed_identities.local.workspace_identity.id,
        var.remote_objects.managed_identities.shared.shared_identity.id
      ]) &&
      azurerm_synapse_workspace.ws.customer_managed_key[0].key_versionless_id == "https://test-kv.vault.azure.net/keys/synapse-key" &&
      azurerm_synapse_workspace.ws.customer_managed_key[0].user_assigned_identity_id == var.remote_objects.managed_identities.local.workspace_identity.id
    )
    error_message = "Local and remote managed identities and customer-managed key options must be preserved."
  }

  assert {
    condition = (
      azurerm_synapse_workspace.ws.github_repo[0].git_url == "https://github.com/contoso/synapse" &&
      azurerm_synapse_firewall_rule.wrkspc_firewall[0].name == "legacy-allow-ci" &&
      azurerm_synapse_firewall_rule.wrkspc_firewalls["ci"].name == "allow-ci" &&
      azurerm_synapse_workspace_aad_admin.wrkspc_aad_admin["0"].login == "synapse-admin"
    )
    error_message = "Git integration, both firewall interfaces, and the workspace administrator must be configured."
  }

  assert {
    condition = (
      azurerm_synapse_workspace.ws.tags.environment == "test" &&
      azurerm_synapse_workspace.ws.tags.cost_center == "analytics" &&
      azurerm_synapse_workspace.ws.tags.owner == "analytics" &&
      azurerm_key_vault_secret.sql_admin_password[0].tags.owner == "analytics"
    )
    error_message = "CAF and workspace tags must be applied to the workspace and generated secrets."
  }

  assert {
    condition = (
      module.spark_pool["spark"].spark_pool.cache_size == 100 &&
      module.spark_pool["spark"].spark_pool.spark_version == "3.5" &&
      module.spark_pool["spark"].spark_pool.dynamic_executor_allocation_enabled &&
      module.spark_pool["spark"].spark_pool.library_requirement[0].filename == "requirements.txt" &&
      module.spark_pool["spark"].spark_pool.spark_config[0].filename == "spark.conf" &&
      module.sql_pool["sql"].sql_pool.create_mode == "PointInTimeRestore" &&
      module.sql_pool["sql"].sql_pool.restore[0].source_database_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Synapse/workspaces/source/sqlPools/source" &&
      module.sql_pool["sql"].sql_pool.data_encrypted
    )
    error_message = "Synapse Spark and SQL pool provider options must be forwarded and available as outputs."
  }
}

run "customer_managed_key_can_replace_sql_credentials" {
  command = plan

  module {
    source = "../modules/analytics/synapse"
  }

  variables {
    global_settings                      = var.global_settings
    client_config                        = var.client_config
    resource_group                       = var.resource_group
    resource_group_name                  = var.resource_group_name
    location                             = var.location
    base_tags                            = var.base_tags
    storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
    vnets                                = var.vnets
    remote_objects                       = var.remote_objects
    private_endpoints                    = var.private_endpoints
    private_dns                          = var.private_dns
    settings = {
      name = "synapse-cmk-only"
      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/workspace"]
      }
      customer_managed_key = {
        key_versionless_id        = "https://test-kv.vault.azure.net/keys/synapse-key"
        user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/workspace"
      }
    }
  }

  assert {
    condition = (
      azurerm_synapse_workspace.ws.sql_administrator_login == null &&
      azurerm_synapse_workspace.ws.sql_administrator_login_password == null &&
      length(random_password.sql_admin) == 0 &&
      length(azurerm_key_vault_secret.sql_admin_password) == 0
    )
    error_message = "Customer-managed-key-only workspaces must not create SQL administrator credentials or secrets."
  }
}

run "fixed_size_spark_pool_without_auto_scale_or_auto_pause" {
  command = plan

  module {
    source = "../modules/analytics/synapse"
  }

  variables {
    global_settings                      = var.global_settings
    client_config                        = var.client_config
    resource_group                       = var.resource_group
    resource_group_name                  = var.resource_group_name
    location                             = var.location
    base_tags                            = var.base_tags
    storage_data_lake_gen2_filesystem_id = var.storage_data_lake_gen2_filesystem_id
    vnets                                = var.vnets
    remote_objects                       = var.remote_objects
    private_endpoints                    = var.private_endpoints
    private_dns                          = var.private_dns
    settings = {
      name                                 = "synapse-fixed-pool"
      sql_administrator_login              = "sqladminuser"
      storage_data_lake_gen2_filesystem_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/contract/blobServices/default/containers/fs"
      synapse_spark_pools = {
        fixed = {
          name             = "spark-fixed"
          node_size_family = "MemoryOptimized"
          node_size        = "Small"
          spark_version    = "3.5"
          node_count       = 3
        }
      }
    }
  }

  assert {
    condition     = module.spark_pool["fixed"].spark_pool.node_count == 3
    error_message = "A fixed-size Spark pool must plan successfully when auto_scale and auto_pause are omitted."
  }
}
