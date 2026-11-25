override_resource {
  target          = module.example.module.api_management_ai_backend["east"].azurecaf_name.resource
  override_during = plan
  values          = { result = "routing-resource" }
}
override_resource {
  target          = module.example.module.api_management_ai_backend["west"].azurecaf_name.resource
  override_during = plan
  values          = { result = "routing-resource" }
}
override_resource {
  target          = module.example.module.api_management_backend_pool["ai"].azurecaf_name.resource
  override_during = plan
  values          = { result = "routing-resource" }
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
            key    = "east"
            source = "ai_backends"
            weight = 50
          },
          {
            key    = "west"
            source = "ai_backends"
            weight = 50
          }
        ]
      }
    }

  }

  assert {
    condition     = length(module.example.api_management_ai_backend) == 2
    error_message = "The examples root must create both configured AI backend modules."
  }
  assert {
    condition     = length(module.example.api_management_backend_pool) == 1
    error_message = "The examples root must create one pool that resolves both AI backend keys."
  }
}
