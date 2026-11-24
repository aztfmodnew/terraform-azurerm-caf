mock_provider "azurerm" {
  source = "./tests/mock_data"
}

mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}

mock_provider "azuread" {
  source = "./tests/mock_data"
}

mock_provider "azapi" {
  source = "./tests/mock_data"
}

mock_provider "external" {
  source = "./tests/mock_data"
}

mock_provider "azurecaf" {}
mock_provider "null" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  global_settings = {
    default_region = "region1"
    regions        = { region1 = "westeurope" }
    random_length  = 0
  }
  logic_app = {
    id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.Web/sites/usage-processor"
    rbac_id = "00000000-0000-0000-0000-000000000042"
  }
  event_hub_namespace = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.EventHub/namespaces/usage-events-ns"
  }
  cosmos_account = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.DocumentDB/databaseAccounts/usage-cosmos"
    name = "usage-cosmos"
  }
}

run "logic_app_is_resolvable_for_standard_and_cosmos_rbac" {
  command = plan

  module {
    source = "../"
  }

  variables {
    global_settings = var.global_settings
    remote_objects = {
      logic_app_standard = {
        local = {
          usage_processor = var.logic_app
        }
      }
      event_hub_namespaces = {
        local = {
          usage_events = var.event_hub_namespace
        }
      }
      cosmos_dbs = {
        local = {
          usage_data = var.cosmos_account
        }
      }
      resource_groups = {
        local = {
          usage_data = {
            id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data"
            name = "usage-data"
          }
        }
      }
    }
    role_mapping = {
      built_in_role_mapping = {
        event_hub_namespaces = {
          usage_events = {
            "Azure Event Hubs Data Receiver" = {
              logic_app_standard = {
                keys = ["usage_processor"]
              }
            }
          }
        }
      }
    }
    database = {
      cosmosdb_role_mapping = {
        built_in_role_mapping = {
          cosmosdb_accounts = {
            usage_data = {
              "Cosmos DB Built-in Data Contributor" = {
                logic_app_standard = {
                  keys               = ["usage_processor"]
                  resource_group_key = "usage_data"
                }
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition = (
      one(values(azurerm_role_assignment.for)).principal_id == var.logic_app.rbac_id &&
      one(values(azurerm_role_assignment.for)).scope == var.event_hub_namespace.id
    )
    error_message = "Standard RBAC mappings must resolve a Logic App Standard principal and the requested scope from combined objects."
  }

  assert {
    condition = (
      azurerm_cosmosdb_sql_role_assignment.cosmos_account[
        "logic_app_standard_usage_data_Cosmos_DB_Built-in_Data_Contributor_usage_processor"
      ].principal_id == var.logic_app.rbac_id &&
      azurerm_cosmosdb_sql_role_assignment.cosmos_account[
        "logic_app_standard_usage_data_Cosmos_DB_Built-in_Data_Contributor_usage_processor"
      ].scope == var.cosmos_account.id
    )
    error_message = "Cosmos SQL RBAC mappings must resolve the Logic App Standard principal and Cosmos account scope."
  }
}
