mock_provider "azurerm" {}

variables {
  global_settings = {
    tags    = {}
    regions = { region1 = "australiaeast" }
  }
  client_config = { landingzone_key = "local" }
  resource_groups = {
    local = {
      dac_test = {
        name     = "test-rg"
        location = "australiaeast"
        tags     = {}
      }
    }
  }
  base_tags      = false
  remote_objects = {}
}

run "omitted_identity_is_supported" {
  command = plan
  module {
    source = "../modules/analytics/databricks_access_connector"
  }
  variables {
    name = "dac-test"
    settings = {
      name               = "dac-test"
      resource_group_key = "dac_test"
    }
  }
  assert {
    condition     = length(azurerm_databricks_access_connector.databricks_access_connector.identity) == 0
    error_message = "Omitting optional identity configuration must not create an identity block."
  }
}
