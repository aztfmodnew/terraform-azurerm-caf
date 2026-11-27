# Run from the repository root:
# terraform test -test-directory=examples/tests/unit/apim/api_management_diagnostics/root -no-color
mock_provider "azurerm" {
  source = "./examples/tests/mock_data"

  mock_resource "azurerm_api_management" {
    override_during = plan
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.ApiManagement/service/gateway"
      location = "westeurope"
      name     = "gateway"
    }
  }
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
    defaults        = { result = "gateway" }
  }
}
mock_provider "random" {}
mock_provider "null" {}
mock_provider "time" {}
mock_provider "tls" {}
mock_provider "local" {}

run "root_apim_profiles_create_diagnostic_settings" {
  command = plan

  module {
    source = "./"
  }

  variables {
    global_settings = {
      default_region = "region1"
      regions        = { region1 = "westeurope" }
      random_length  = 0
    }
    resource_groups = {
      observability = {
        name     = "observability"
        location = "westeurope"
      }
    }
    apim = {
      api_management = {
        gateway = {
          name            = "gateway"
          region          = "region1"
          publisher_name  = "Gateway"
          publisher_email = "gateway@example.com"
          sku_name        = "Developer_1"
          resource_group = {
            key = "observability"
          }
          diagnostic_profiles = {
            platform = {
              name             = "gateway-platform"
              definition_key   = "api_management"
              destination_type = ["log_analytics"]
              destination_key  = "workspace"
            }
          }
        }
      }
    }
    diagnostics = {
      diagnostics_definition = {
        api_management = {
          name = "gateway"
          categories = {
            log    = [["GatewayLogs", true, false, 0]]
            metric = [["AllMetrics", true, false, 0]]
          }
        }
      }
      diagnostics_destinations = {
        log_analytics = {
          workspace = {
            log_analytics_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.OperationalInsights/workspaces/gateway"
          }
        }
      }
    }
  }

  assert {
    condition = (
      output.api_management_diagnostics["gateway"].diagnostic_settings["platform"].target_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.ApiManagement/service/gateway" &&
      output.api_management_diagnostics["gateway"].diagnostic_settings["platform"].log_analytics_workspace_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.OperationalInsights/workspaces/gateway"
    )
    error_message = "Root APIM diagnostic profiles must be forwarded to the diagnostics module with the expected target and destination."
  }
}
