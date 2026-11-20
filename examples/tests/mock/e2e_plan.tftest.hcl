mock_provider "azurerm" {
  source = "./tests/mock_data"

  mock_resource "azurerm_resource_group_template_deployment" {
    defaults = {
      output_content = "{\"id\":{\"type\":\"String\",\"value\":\"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-ase\"},\"objectId\":{\"type\":\"String\",\"value\":\"00000000-0000-0000-0000-000000000001\"}}"
    }
  }
}

mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}

mock_provider "azuread" {
  source = "./tests/mock_data"
}

mock_provider "external" {
  source = "./tests/mock_data"
}

run "test_plan" {
  command = plan

  variables {
    global_settings = {
      default_region = "region1"
      regions        = { region1 = "westeurope" }
      random_length  = 0
    }
    resource_groups = {
      gateway = {
        name   = "ai-gateway"
        region = "region1"
      }
    }
    api_management = {
      gateway = {
        name            = "ai-gateway"
        region          = "region1"
        resource_group  = { key = "gateway" }
        publisher_name  = "AI Gateway"
        publisher_email = "gateway@example.com"
        sku_name        = "Developer_1"
      }
    }
    api_management_named_value = {
      backend_endpoint = {
        name           = "backend-endpoint"
        display_name   = "backend-endpoint"
        value          = "https://backend.example.com"
        tags           = ["ai-gateway"]
        resource_group = { key = "gateway" }
        api_management = { key = "gateway" }
      }
      backend_token = {
        name           = "backend-token"
        display_name   = "backend-token"
        secret         = true
        resource_group = { key = "gateway" }
        api_management = { key = "gateway" }
        value_from_key_vault = {
          secret_id = "https://mock-vault.vault.azure.net/secrets/backend-token"
        }
      }
    }
  }

  assert {
    condition = (
      length(module.example.api_management) == 1 &&
      length(module.example.api_management_named_value) == 2 &&
      module.example.api_management_named_value["backend_endpoint"].display_name == "backend-endpoint" &&
      module.example.api_management_named_value["backend_token"].display_name == "backend-token"
    )
    error_message = "The mock plan must include one APIM service and both literal and Key Vault-backed named-value module objects."
  }
}
