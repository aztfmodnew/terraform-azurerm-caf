mock_provider "azurerm" {
  mock_resource "azurerm_logic_app_standard" {
    override_during = plan
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.Web/sites/usage-processor"
      location = "westeurope"
      name     = "usage-processor"
    }
  }
}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "usage-processor" }
  }
}

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
  resource_groups = {
    local = {
      usage_data = {
        name     = "usage-data"
        location = "westeurope"
      }
    }
  }
  storage_accounts = {
    local = {
      runtime = {
        id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.Storage/storageAccounts/usagedataruntime"
        name               = "usagedataruntime"
        primary_access_key = "mock-key"
      }
    }
  }
  service_plans = {
    local = {
      processor = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/usage-data/providers/Microsoft.Web/serverFarms/usage-processor"
      }
    }
  }
  combined_objects = {
    cosmos_dbs = {
      local = {
        usage = {
          endpoint = "https://usage-cosmos.documents.azure.com:443/"
        }
      }
    }
    event_hub_namespaces = {
      local = {
        usage = {
          name = "usage-events-ns"
        }
      }
    }
    event_hubs = {
      remote = {
        events = {
          name = "usage-events"
        }
      }
    }
  }
  diagnostics = {
    diagnostics_definition = {
      logic_app_usage = {
        name = "usage-logic-app"
        categories = {
          metric = [["AllMetrics", true, false, 0]]
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

run "dynamic_app_settings_and_diagnostics_are_forwarded" {
  command = plan

  module {
    source = "../modules/logic_app/standard"
  }

  variables {
    global_settings  = var.global_settings
    client_config    = var.client_config
    resource_groups  = var.resource_groups
    storage_accounts = var.storage_accounts
    service_plans    = var.service_plans
    combined_objects = var.combined_objects
    subnets          = {}
    base_tags        = { environment = "test" }
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "node"
      EVENT_HUB_NAME           = "static-value"
    }
    diagnostics = var.diagnostics
    settings = {
      name                = "usage-processor"
      resource_group_key  = "usage_data"
      storage_account_key = "runtime"
      service_plan_key    = "processor"
      identity            = { type = "SystemAssigned" }
      tags                = { workload = "usage-data" }
      dynamic_app_settings = {
        COSMOS_ACCOUNT_ENDPOINT = {
          cosmos_dbs = {
            usage = {
              attribute_key = "endpoint"
            }
          }
        }
        EVENT_HUB_NAMESPACE_NAME = {
          event_hub_namespaces = {
            usage = {
              attribute_key = "name"
            }
          }
        }
        EVENT_HUB_NAME = {
          event_hubs = {
            events = {
              lz_key        = "remote"
              attribute_key = "name"
            }
          }
        }
      }
      diagnostic_profiles = {
        operations = {
          name             = "usage-logic-app"
          definition_key   = "logic_app_usage"
          destination_type = ["log_analytics"]
          destination_key  = "usage"
        }
        audit = {
          name             = "usage-logic-app-audit"
          definition_key   = "logic_app_usage"
          destination_type = ["log_analytics"]
          destination_key  = "usage"
        }
      }
      timeouts = {
        create = "60m"
        update = "60m"
        delete = "60m"
      }
    }
  }

  assert {
    condition = (
      azurerm_logic_app_standard.logic_app_standard.app_settings["COSMOS_ACCOUNT_ENDPOINT"] == var.combined_objects.cosmos_dbs.local.usage.endpoint &&
      azurerm_logic_app_standard.logic_app_standard.app_settings["EVENT_HUB_NAMESPACE_NAME"] == var.combined_objects.event_hub_namespaces.local.usage.name &&
      azurerm_logic_app_standard.logic_app_standard.app_settings["EVENT_HUB_NAME"] == var.combined_objects.event_hubs.remote.events.name &&
      azurerm_logic_app_standard.logic_app_standard.app_settings["FUNCTIONS_WORKER_RUNTIME"] == "node" &&
      azurerm_logic_app_standard.logic_app_standard.timeouts.create == "60m" &&
      azurerm_logic_app_standard.logic_app_standard.tags.environment == "test" &&
      azurerm_logic_app_standard.logic_app_standard.tags.workload == "usage-data"
    )
    error_message = "Logic App settings must resolve local and remote references, preserve static settings, merge tags, and forward timeouts."
  }

  assert {
    condition = (
      length(module.diagnostics) == 2 &&
      length(module.diagnostics["operations"].diagnostic_settings) == 1 &&
      length(module.diagnostics["audit"].diagnostic_settings) == 1 &&
      module.diagnostics["operations"].diagnostic_settings["operations"].target_resource_id == azurerm_logic_app_standard.logic_app_standard.id &&
      module.diagnostics["operations"].diagnostic_settings["operations"].log_analytics_workspace_id == var.diagnostics.diagnostics_destinations.log_analytics.usage.log_analytics_resource_id &&
      module.diagnostics["audit"].diagnostic_settings["audit"].target_resource_id == azurerm_logic_app_standard.logic_app_standard.id
    )
    error_message = "Each Logic App diagnostic module instance must own exactly one profile and use the resolved destination."
  }
}
