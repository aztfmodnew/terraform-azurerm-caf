mock_provider "azapi" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "routing-resource" }
  }
}
mock_provider "azurerm" {}
mock_provider "azurerm" {
  alias = "vhub"
}
mock_provider "azuread" {}

run "examples_root_creates_ai_backends_and_pool" {
  command = plan

  variables {
    global_settings = {
      default_region = "region1"
      regions        = { region1 = "westeurope" }
      random_length  = 0
      passthrough    = true
      use_slug       = false
    }
    api_management_ai_backend = {
      east = {
        name              = "ai-east"
        endpoint          = "https://ai-east.example.invalid"
        api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      }
      west = {
        name              = "ai-west"
        endpoint          = "https://ai-west.example.invalid"
        api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      }
    }
    api_management_backend_pool = {
      ai = {
        name              = "ai-pool"
        api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
        services = [
          {
            id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/east"
            weight = 50
          },
          {
            id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/west"
            weight = 50
          }
        ]
      }
    }
  }

  assert {
    condition     = length(module.example.api_management_ai_backend) >= 1
    error_message = "The examples root must pass api_management_ai_backend through and plan at least one resource."
  }
  assert {
    condition     = length(module.example.api_management_backend_pool) >= 1
    error_message = "The examples root must pass api_management_backend_pool through and plan at least one resource."
  }
}
