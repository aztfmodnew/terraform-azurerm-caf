mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "mock-linux-web-app" }
  }
}
mock_provider "azapi" {}

run "legacy_ruby_version_is_rejected_explicitly" {
  command = plan
  module {
    source = "../modules/webapps/linux_web_app"
  }
  variables {
    global_settings = {
      prefixes      = []
      suffixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config     = { landingzone_key = "local" }
    location          = "westeurope"
    resource_group    = { name = "mock-rg", location = "westeurope", tags = {} }
    base_tags         = false
    remote_objects    = {}
    private_endpoints = {}
    settings = {
      name            = "mock-linux-web-app"
      service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/serverfarms/mock-plan"
      site_config = {
        application_stack = {
          ruby_version = "2.7"
        }
      }
    }
  }
  expect_failures = [azurerm_linux_web_app.linux_web_app]
}
