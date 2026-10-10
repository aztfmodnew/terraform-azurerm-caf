mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {
    defaults = {
      id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.KeyVault/vaults/migrationtest"
      vault_uri = "https://migrationtest.vault.azure.net/"
    }
  }
}
mock_provider "azuread" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings = {
    prefixes       = []
    random_length  = 0
    passthrough    = true
    use_slug       = false
    environment    = "test"
    default_region = "region1"
    regions        = { region1 = "westeurope" }
  }
  client_config = {
    landingzone_key = "local"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
  }
  location            = "westeurope"
  resource_group_name = "migrationtest"
  resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags           = false
  remote_objects      = {}
  private_endpoints   = {}
  resource_groups     = {}
  vnets               = {}
  diagnostics         = { diagnostics_definition = {} }
}

run "frontdoor_legacy_rewrite_and_negation" {
  command = plan
  module {
    source = "../modules/cdn/cdn_frontdoor_profile/rule"
  }
  variables {
    settings = {
      name                      = "migrationtest"
      cdn_frontdoor_rule_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Cdn/profiles/test/ruleSets/test"
      order                     = 1
      behavior_on_match         = "Stop"
      actions = [{
        url_rewrite_action    = { destination = "/new", source_pattern = "/old", preserve_unmatched_path = true }
        request_header_action = [{ header_action = "Overwrite", header_name = "X-Test", value = "legacy" }]
      }]
      conditions = [{
        query_string_condition   = [{ operator = "Contains", match_values = ["test"], negate_condition = true }]
        request_header_condition = [{ header_name = "X-Test", operator = "Any", match_values = [] }]
      }]
    }
  }
  assert {
    condition     = azurerm_cdn_frontdoor_rule.rule.behaviour_on_match == "Stop" && azurerm_cdn_frontdoor_rule.rule.actions[0].url_rewrite[0].destination_path == "/new" && azurerm_cdn_frontdoor_rule.rule.actions[0].url_rewrite[0].preserve_unmatched_path_enabled
    error_message = "Legacy Front Door rewrite settings were not preserved."
  }
  assert {
    condition     = azurerm_cdn_frontdoor_rule.rule.conditions[0].query_string[0].operator == "NotContains" && azurerm_cdn_frontdoor_rule.rule.conditions[0].request_header[0].name == "X-Test" && azurerm_cdn_frontdoor_rule.rule.conditions[0].request_header[0].values == null
    error_message = "Legacy negation or Any condition semantics were not preserved."
  }
}
run "frontdoor_current_names_take_precedence" {
  command = plan
  module {
    source = "../modules/cdn/cdn_frontdoor_profile/rule"
  }
  variables {
    settings = {
      name                      = "migrationtest"
      cdn_frontdoor_rule_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Cdn/profiles/test/ruleSets/test"
      order                     = 1
      behaviour_on_match        = "Continue"
      behavior_on_match         = "Stop"
      actions = [{
        url_redirect = { redirect_type = "Found", destination_host_name = "current.example.com", destination_hostname = "legacy.example.com" }
      }]
      conditions = [{
        request_method = [{ operator = "NotEqual", values = ["POST"], match_values = ["GET"] }]
      }]
    }
  }
  assert {
    condition     = azurerm_cdn_frontdoor_rule.rule.behaviour_on_match == "Continue" && azurerm_cdn_frontdoor_rule.rule.actions[0].url_redirect[0].destination_host_name == "current.example.com" && azurerm_cdn_frontdoor_rule.rule.conditions[0].request_method[0].values == toset(["POST"])
    error_message = "Current Front Door names must take precedence over legacy names."
  }
}
run "frontdoor_legacy_cache_and_origin" {
  command = plan
  module {
    source = "../modules/cdn/cdn_frontdoor_profile/rule"
  }
  variables {
    remote_objects = {
      cdn_frontdoor_origin_groups = {
        local = {
          origin = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Cdn/profiles/test/originGroups/test" }
        }
      }
    }
    settings = {
      name                      = "migrationtest"
      cdn_frontdoor_rule_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Cdn/profiles/test/ruleSets/test"
      order                     = 1
      actions = [{
        route_configuration_override_action = {
          cache_behavior      = "OverrideAlways"
          cache_duration      = "01:00:00"
          origin_group        = { key = "origin" }
          forwarding_protocol = "HttpsOnly"
          compression_enabled = false
        }
      }]
    }
  }
  assert {
    condition     = azurerm_cdn_frontdoor_rule.rule.actions[0].route_configuration_override[0].caching[0].duration == "01:00:00" && azurerm_cdn_frontdoor_rule.rule.actions[0].route_configuration_override[0].origin_group[0].forwarding_protocol == "HttpsOnly" && !azurerm_cdn_frontdoor_rule.rule.actions[0].route_configuration_override[0].caching[0].compression_enabled
    error_message = "Legacy cache duration, origin lookup, and explicit false must be preserved."
  }
}
run "frontdoor_disabled_cache_without_origin" {
  command = plan
  module {
    source = "../modules/cdn/cdn_frontdoor_profile/rule"
  }
  variables {
    settings = {
      name                      = "migrationtest"
      cdn_frontdoor_rule_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Cdn/profiles/test/ruleSets/test"
      order                     = 1
      actions                   = [{ route_configuration_override = { caching = { behaviour = "Disabled" } } }]
    }
  }
  assert {
    condition     = azurerm_cdn_frontdoor_rule.rule.actions[0].route_configuration_override[0].caching[0].query_string_behaviour == null && length(azurerm_cdn_frontdoor_rule.rule.actions[0].route_configuration_override[0].origin_group) == 0
    error_message = "Disabled caching must not inject a query-string policy or require an origin."
  }
}
