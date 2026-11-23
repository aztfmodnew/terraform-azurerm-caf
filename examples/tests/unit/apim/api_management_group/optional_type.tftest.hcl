mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-group" }
  }
}

run "explicit_null_group_type_defers_to_provider" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name           = "example-group"
      display_name   = "Example Group"
      type           = null
      api_management = { name = "example-apim" }
      resource_group = { name = "example-rg" }
    }
  }

  assert {
    condition     = var.settings.type == null && azurerm_api_management_group.apim.display_name == "Example Group" && output.name == "example-group"
    error_message = "The optional group type must accept explicit null while keeping the provider default."
  }
}
