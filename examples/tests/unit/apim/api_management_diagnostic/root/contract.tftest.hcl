# Run from the repository root:
# terraform test -test-directory=examples/tests/unit/apim/api_management_diagnostic/root -no-color
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

run "root_resolves_builtin_azuremonitor_logger" {
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
        }
      }
      api_management_diagnostic = {
        service = {
          identifier = "azuremonitor"
          api_management = {
            key = "gateway"
          }
          resource_group = {
            key = "observability"
          }
        }
      }
    }
  }

  assert {
    condition     = length(output.api_management_diagnostic) == 1
    error_message = "An azuremonitor service diagnostic must derive the APIM built-in logger without an explicit logger reference."
  }
}
