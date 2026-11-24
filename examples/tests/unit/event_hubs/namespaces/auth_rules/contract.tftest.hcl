mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "send-listen" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = false
    use_slug      = true
  }
  client_config       = { landingzone_key = "local" }
  namespace_name      = "namespace"
  resource_group_name = "test"
  settings = {
    rule_name = "send-listen"
    listen    = true
    send      = true
    manage    = false
    timeouts = {
      create = "30m"
      update = "30m"
    }
  }
}

run "authorization_rule_name_output" {
  command = plan
  module {
    source = "../modules/event_hubs/namespaces/auth_rules"
  }

  assert {
    condition     = output.name == "send-listen"
    error_message = "The authorization rule name output must expose the rule name, not the namespace name."
  }
}
