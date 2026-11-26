# Run from the repository root:
# terraform test -test-directory=examples/tests/unit/apim/api_management_logger/root -no-color
mock_provider "azurerm" {
  source = "./examples/tests/mock_data"
}
mock_provider "azurerm" {
  alias  = "vhub"
  source = "./examples/tests/mock_data"
}
mock_provider "azuread" {
  source = "./examples/tests/mock_data"
}
mock_provider "azapi" {
  source = "./examples/tests/mock_data"
}
mock_provider "external" {
  source = "./examples/tests/mock_data"
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "gateway-logger" }
  }
}
mock_provider "null" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  global_settings = {
    default_region = "region1"
    regions        = { region1 = "westeurope" }
    random_length  = 0
  }
  remote_objects = {
    event_hub_namespaces = {
      local = {
        gateway = {
          id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.EventHub/namespaces/gateway"
          name = "gateway"
        }
      }
    }
    event_hubs = {
      local = {
        telemetry = {
          id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.EventHub/namespaces/gateway/eventhubs/telemetry"
          name = "telemetry"
        }
      }
    }
    managed_identities = {
      local = {
        gateway = {
          client_id = "00000000-0000-0000-0000-000000000010"
          rbac_id   = "00000000-0000-0000-0000-000000000010"
        }
      }
    }
  }
  apim = {
    api_management_logger = {
      eventhub = {
        name                = "gateway-logger"
        resource_group_name = "observability"
        api_management = {
          name = "gateway"
        }
        eventhub = {
          event_hub_namespace = { key = "gateway" }
          event_hub           = { key = "telemetry" }
          managed_identity    = { key = "gateway" }
        }
      }
    }
  }
}

run "logger_plans_with_no_generic_role_assignment_waiter" {
  command = plan

  assert {
    condition = (
      length(output.api_management_logger) == 1 &&
      length(time_sleep.azurerm_role_assignment_for) == 0
    )
    error_message = "A logger must plan when the role-assignment propagation waiter has count zero."
  }
}

run "logger_plans_after_eventhub_data_sender_waiter" {
  command = plan

  variables {
    role_mapping = {
      built_in_role_mapping = {
        event_hub_namespaces = {
          gateway = {
            "Azure Event Hubs Data Sender" = {
              managed_identities = {
                keys = ["gateway"]
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition = (
      length(output.api_management_logger) == 1 &&
      length(azurerm_role_assignment.for) == 1 &&
      one(values(azurerm_role_assignment.for)).role_definition_name == "Azure Event Hubs Data Sender" &&
      length(time_sleep.azurerm_role_assignment_for) == 1
    )
    error_message = "The root logger contract must plan with its Event Hub sender assignment and propagation waiter."
  }
}
