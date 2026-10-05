mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "mock-plan" }
  }
}

run "v3_key_resolves_environment_id" {
  command = plan
  module {
    source = "../modules/webapps/service_plan"
  }
  variables {
    settings = {
      name                           = "mock-plan"
      os_type                        = "Linux"
      sku_name                       = "I1v2"
      app_service_environment_v3_key = "ase1"
    }
    location       = "westeurope"
    resource_group = { name = "mock-rg", location = "westeurope", tags = {} }
    base_tags      = false
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    remote_objects = {
      app_service_environments_v3 = {
        local = {
          ase1 = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-asev3"
          }
        }
      }
    }
    client_config = { landingzone_key = "local" }
  }
  assert {
    condition     = azurerm_service_plan.sp.app_service_environment_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-asev3"
    error_message = "The ASEv3 reference key must resolve to the App Service Plan environment ID."
  }
}
