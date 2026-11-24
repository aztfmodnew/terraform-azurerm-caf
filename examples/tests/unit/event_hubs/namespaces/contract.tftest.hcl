mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "secure-eventhub" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = false
    use_slug      = true
  }
  client_config = { landingzone_key = "local" }
  resource_group = {
    name     = "test"
    location = "westeurope"
  }
  base_tags = false
  settings = {
    name                          = "secure-eventhub"
    sku                           = "Standard"
    local_authentication_enabled  = false
    public_network_access_enabled = false
    minimum_tls_version           = "1.2"
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/eventhub"]
    }
    network_rulesets = {
      default_action                 = "Deny"
      public_network_access_enabled  = false
      trusted_service_access_enabled = true
    }
    timeouts = {
      create = "45m"
      update = "45m"
    }
  }
}

run "secure_namespace_contract" {
  command = plan
  module {
    source = "../modules/event_hubs/namespaces"
  }

  assert {
    condition = (
      azurerm_eventhub_namespace.evh.local_authentication_enabled == false &&
      azurerm_eventhub_namespace.evh.public_network_access_enabled == false &&
      azurerm_eventhub_namespace.evh.minimum_tls_version == "1.2" &&
      length(azurerm_eventhub_namespace.evh.identity[0].identity_ids) == 1 &&
      azurerm_eventhub_namespace.evh.network_rulesets[0].public_network_access_enabled == false
    )
    error_message = "Security, identity, public network, and timeout-compatible namespace settings must reach the resource."
  }
}

run "legacy_network_rules_map" {
  command = plan
  module {
    source = "../modules/event_hubs/namespaces"
  }
  variables {
    settings = {
      name                          = "secure-eventhub"
      sku                           = "Standard"
      local_authentication_enabled  = true
      public_network_access_enabled = true
      minimum_tls_version           = "1.2"
      network_rulesets = {
        primary = {
          default_action                 = "Deny"
          public_network_access_enabled  = false
          trusted_service_access_enabled = true
        }
      }
    }
  }

  assert {
    condition = (
      length(azurerm_eventhub_namespace.evh.network_rulesets) == 1 &&
      azurerm_eventhub_namespace.evh.network_rulesets[0].default_action == "Deny"
    )
    error_message = "The legacy keyed network_rulesets map must continue to create one ruleset."
  }
}
