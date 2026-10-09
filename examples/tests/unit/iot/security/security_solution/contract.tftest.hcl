mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

run "iot_security_legacy_recommendations_and_enabled" {
  command = plan
  module {
    source = "../modules/iot/security/security_solution"
  }
  variables {
    base_tags           = false
    global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
    location            = "westeurope"
    resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
    resource_group_name = "migrationtest"
    iothub_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Devices/iotHubs/test"
    ]
    settings = {
      name                  = "migrationtest"
      display_name          = "Migration test"
      enabled               = true
      disabled_data_sources = ["TwinData"]
      recommendations_enabled = {
        baseline   = false
        open_ports = false
      }
    }
  }
  assert {
    condition     = azurerm_iot_security_solution.securitysolution.enabled && !azurerm_iot_security_solution.securitysolution.recommendations[0].baseline && !azurerm_iot_security_solution.securitysolution.recommendations[0].open_ports
    error_message = "The legacy recommendations block and explicit enabled=true must map to current resource arguments."
  }
}
run "iot_security_current_recommendations_take_precedence" {
  command = plan
  module {
    source = "../modules/iot/security/security_solution"
  }
  variables {
    base_tags           = false
    global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
    location            = "westeurope"
    resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
    resource_group_name = "migrationtest"
    iothub_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Devices/iotHubs/test"
    ]
    settings = {
      name                    = "migrationtest"
      display_name            = "Migration test"
      recommendations_enabled = { baseline = false }
      recommendations         = { baseline = true }
    }
  }
  assert {
    condition     = azurerm_iot_security_solution.securitysolution.recommendations[0].baseline
    error_message = "The current recommendations object must take precedence over the legacy alias."
  }
}
