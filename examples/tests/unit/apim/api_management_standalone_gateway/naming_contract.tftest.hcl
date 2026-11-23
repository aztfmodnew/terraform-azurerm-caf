mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults = {
      result = "caf-standalone"
    }
  }
}

override_resource {
  target          = azurecaf_name.generated
  override_during = plan
  values = {
    result = "prefix-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-abcde"
  }
}

variables {
  global_settings = {
    prefixes      = ["prefix"]
    random_length = 5
    passthrough   = false
    use_slug      = true
  }
  client_config  = { landingzone_key = "local" }
  remote_objects = {}
}

run "gateway_name_is_limited_while_random_suffix_is_preserved" {
  command = plan
  module {
    source = "../modules/apim/api_management_standalone_gateway"
  }
  variables {
    settings = {
      name                = "long-gateway-name"
      resource_group_name = "example-rg"
      location            = "westeurope"
      sku                 = { name = "WorkspaceGatewayPremium" }
    }
  }
  assert {
    condition = (
      length(azurecaf_name.resource.name) == 45 &&
      endswith(azurecaf_name.resource.name, "-abcde") &&
      azurecaf_name.resource.passthrough
    )
    error_message = "The complete standalone gateway name must be at most 45 characters and retain its random uniqueness suffix."
  }
}
