mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-tag" }
  }
}

run "api_operation_tag_provider_options" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation_tag"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config    = { landingzone_key = "local" }
    base_tags        = {}
    remote_objects   = {}
    api_operation_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api/operations/sample-operation"
    settings = {
      name         = "example-tag"
      display_name = "Example Tag"
      api_operation = {
        key = "sample-operation"
      }
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation_tag.apim.api_operation_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api/operations/sample-operation"
    error_message = "The API operation ID must be passed to the tag resource."
  }
  assert {
    condition     = azurerm_api_management_api_operation_tag.apim.name == "example-tag"
    error_message = "The tag name must use the CAF-generated name."
  }
  assert {
    condition     = azurerm_api_management_api_operation_tag.apim.display_name == "Example Tag"
    error_message = "The required tag display name must be passed to the resource."
  }
  assert {
    condition     = azurerm_api_management_api_operation_tag.apim.timeouts.update == "40m"
    error_message = "The API operation tag timeouts must be passed to the provider."
  }
}
