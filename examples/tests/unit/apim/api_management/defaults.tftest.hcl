mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "example-apim" }
  }
}

variables {
  base_tags           = false
  client_config       = { landingzone_key = "local" }
  global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
  location            = "westeurope"
  resource_group      = { name = "example-rg", location = "westeurope", tags = {} }
  resource_group_name = "example-rg"
  remote_objects      = {}
  public_ip_addresses = {}
  vnets               = {}
}

run "omitted_settings_preserve_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management"
  }
  variables {
    settings = {
      name            = "example-apim"
      publisher_name  = "Example"
      publisher_email = "owner@example.com"
      sku_name        = "Developer_1"
      delegation      = {}
    }
  }
  assert {
    condition     = azurerm_api_management.apim.public_network_access_enabled == true && azurerm_api_management.apim.virtual_network_type == "None"
    error_message = "Omitted typed settings must retain public access and no virtual network."
  }
  assert {
    condition     = one(azurerm_api_management.apim.delegation).subscriptions_enabled == null && one(azurerm_api_management.apim.delegation).user_registration_enabled == null
    error_message = "Omitted delegation flags must remain unset for provider default handling."
  }
}

run "explicit_null_settings_preserve_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management"
  }
  variables {
    settings = {
      name                          = "example-apim"
      publisher_name                = "Example"
      publisher_email               = "owner@example.com"
      sku_name                      = "Developer_1"
      public_network_access_enabled = null
      virtual_network_type          = null
      delegation = {
        subscriptions_enabled     = null
        user_registration_enabled = null
      }
    }
  }
  assert {
    condition     = azurerm_api_management.apim.public_network_access_enabled == true && azurerm_api_management.apim.virtual_network_type == "None"
    error_message = "Explicit null settings must retain the provider's service defaults."
  }
  assert {
    condition     = one(azurerm_api_management.apim.delegation).subscriptions_enabled == null && one(azurerm_api_management.apim.delegation).user_registration_enabled == null
    error_message = "Explicit null delegation flags must remain unset, not be forced to false by the module."
  }
}
