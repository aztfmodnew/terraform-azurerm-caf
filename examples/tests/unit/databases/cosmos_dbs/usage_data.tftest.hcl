mock_provider "azurerm" {
  mock_resource "azurerm_cosmosdb_account" {
    override_during = plan
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.DocumentDB/databaseAccounts/usage-cosmos"
      endpoint            = "https://usage-cosmos.documents.azure.com:443/"
      location            = "westeurope"
      name                = "usage-cosmos"
      resource_group_name = "usage-data"
    }
  }
}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "usage-cosmos" }
  }
}

mock_provider "random" {}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
    regions       = { region1 = "westeurope" }
  }
  client_config = {
    landingzone_key = "local"
  }
  resource_group = {
    name     = "usage-data"
    location = "westeurope"
    tags     = {}
  }
  diagnostics = {
    diagnostics_definition = {
      cosmosdb_usage = {
        name = "usage-cosmos"
        categories = {
          log    = [["DataPlaneRequests", true, false, 0]]
          metric = [["Requests", true, false, 0]]
        }
      }
    }
    diagnostics_destinations = {
      log_analytics = {
        usage = {
          log_analytics_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.OperationalInsights/workspaces/usage"
        }
      }
    }
  }
}

run "cosmos_account_timeouts_and_diagnostics_are_forwarded" {
  command = plan

  module {
    source = "../modules/databases/cosmos_dbs"
  }

  variables {
    global_settings     = var.global_settings
    client_config       = var.client_config
    location            = "westeurope"
    resource_group_name = var.resource_group.name
    resource_group      = var.resource_group
    resource_groups     = {}
    private_endpoints   = {}
    vnets               = {}
    base_tags           = false
    diagnostics         = var.diagnostics
    settings = {
      name       = "usage-cosmos"
      offer_type = "Standard"
      consistency_policy = {
        consistency_level = "Session"
      }
      geo_locations = {
        primary = {
          region            = "region1"
          failover_priority = 0
        }
      }
      diagnostic_profiles = {
        operations = {
          name             = "usage-cosmos"
          definition_key   = "cosmosdb_usage"
          destination_type = ["log_analytics"]
          destination_key  = "usage"
        }
        audit = {
          name             = "usage-cosmos-audit"
          definition_key   = "cosmosdb_usage"
          destination_type = ["log_analytics"]
          destination_key  = "usage"
        }
      }
      timeouts = {
        create = "90m"
        read   = "10m"
        update = "90m"
        delete = "90m"
      }
    }
  }

  assert {
    condition = (
      azurerm_cosmosdb_account.cosmos_account.timeouts.create == "90m" &&
      azurerm_cosmosdb_account.cosmos_account.timeouts.read == "10m" &&
      azurerm_cosmosdb_account.cosmos_account.timeouts.update == "90m" &&
      azurerm_cosmosdb_account.cosmos_account.timeouts.delete == "90m"
    )
    error_message = "Cosmos account timeouts must be forwarded to the provider."
  }

  assert {
    condition = (
      length(module.diagnostics) == 2 &&
      length(module.diagnostics["operations"].diagnostic_settings) == 1 &&
      length(module.diagnostics["audit"].diagnostic_settings) == 1 &&
      module.diagnostics["operations"].diagnostic_settings["operations"].target_resource_id == azurerm_cosmosdb_account.cosmos_account.id &&
      module.diagnostics["operations"].diagnostic_settings["operations"].log_analytics_workspace_id == var.diagnostics.diagnostics_destinations.log_analytics.usage.log_analytics_resource_id &&
      module.diagnostics["audit"].diagnostic_settings["audit"].target_resource_id == azurerm_cosmosdb_account.cosmos_account.id
    )
    error_message = "Each Cosmos diagnostic module instance must own exactly one profile and use the resolved account destination."
  }
}

run "sql_database_and_container_optional_contracts_are_forwarded" {
  command = plan

  module {
    source = "../modules/databases/cosmos_dbs/sql_database"
  }

  variables {
    global_settings       = var.global_settings
    resource_group_name   = var.resource_group.name
    location              = "westeurope"
    cosmosdb_account_name = "usage-cosmos"
    settings = {
      name        = "usage"
      add_rnd_num = false
      autoscale_settings = {
        max_throughput = 1000
      }
      timeouts = {
        create = "45m"
        read   = "5m"
        update = "45m"
        delete = "45m"
      }
      containers = {
        records = {
          name                   = "usage-records"
          partition_key_paths    = ["/tenantId"]
          partition_key_kind     = "Hash"
          partition_key_version  = 2
          analytical_storage_ttl = -1
          default_ttl            = 2592000
          conflict_resolution_policy = {
            mode                     = "LastWriterWins"
            conflict_resolution_path = "/_ts"
          }
          timeouts = {
            create = "30m"
            read   = "3m"
            update = "30m"
            delete = "30m"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azurerm_cosmosdb_sql_database.database.name == "usage" &&
      azurerm_cosmosdb_sql_database.database.autoscale_settings[0].max_throughput == 1000 &&
      azurerm_cosmosdb_sql_database.database.timeouts.create == "45m" &&
      azurerm_cosmosdb_sql_database.database.timeouts.read == "5m"
    )
    error_message = "SQL database naming, autoscale, and timeout settings must be applied without a provider planning conflict."
  }

  assert {
    condition = (
      azurerm_cosmosdb_sql_container.container["records"].partition_key_kind == "Hash" &&
      azurerm_cosmosdb_sql_container.container["records"].partition_key_version == 2 &&
      azurerm_cosmosdb_sql_container.container["records"].analytical_storage_ttl == -1 &&
      azurerm_cosmosdb_sql_container.container["records"].default_ttl == 2592000 &&
      azurerm_cosmosdb_sql_container.container["records"].conflict_resolution_policy[0].mode == "LastWriterWins" &&
      azurerm_cosmosdb_sql_container.container["records"].conflict_resolution_policy[0].conflict_resolution_path == "/_ts" &&
      azurerm_cosmosdb_sql_container.container["records"].timeouts.create == "30m"
    )
    error_message = "SQL container partition, analytical storage, TTL, conflict-resolution, and timeout settings must be forwarded."
  }
}
