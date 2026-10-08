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

run "cosmos_legacy_disabled_inverts_to_enabled" {
  command = plan
  module {
    source = "../modules/databases/cosmos_dbs"
  }
  variables {
    settings = {
      name                          = "migrationtest"
      offer_type                    = "Standard"
      local_authentication_disabled = true
      consistency_policy            = { consistency_level = "Session" }
      geo_locations                 = { primary = { location = "westeurope", failover_priority = 0 } }
    }
  }
  assert {
    condition     = !azurerm_cosmosdb_account.cosmos_account.local_authentication_enabled
    error_message = "Legacy disabled=true must map to enabled=false."
  }
}

run "cosmos_current_false_takes_precedence" {
  command = plan
  module {
    source = "../modules/databases/cosmos_dbs"
  }
  variables {
    settings = {
      name                          = "migrationtest"
      offer_type                    = "Standard"
      local_authentication_enabled  = false
      local_authentication_disabled = false
      consistency_policy            = { consistency_level = "Session" }
      geo_locations                 = { primary = { location = "westeurope", failover_priority = 0 } }
    }
  }
  assert {
    condition     = !azurerm_cosmosdb_account.cosmos_account.local_authentication_enabled
    error_message = "Current enabled=false must take precedence over legacy disabled=false."
  }
}

run "lb_legacy_booleans" {
  command = plan
  module {
    source = "../modules/networking/lb_rule"
  }
  variables {
    base_tags                = {}
    backend_address_pool_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/loadBalancers/test/backendAddressPools/test"]
    probe_id                 = null
    settings = {
      name                           = "migrationtest"
      loadbalancer                   = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/loadBalancers/test" }
      frontend_ip_configuration_name = "frontend"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      enable_floating_ip             = false
      enable_tcp_reset               = true
    }
  }
  assert {
    condition     = !azurerm_lb_rule.lb.floating_ip_enabled && azurerm_lb_rule.lb.tcp_reset_enabled
    error_message = "Legacy LB booleans must preserve explicit false and true."
  }
}

run "pipeline_legacy_spelling" {
  command = plan
  module {
    source = "../modules/data_factory/data_factory_pipeline"
  }
  variables {
    data_factory_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.DataFactory/factories/test"
    settings        = { name = "migrationtest", moniter_metrics_after_duration = "00:10:00" }
  }
  assert {
    condition     = azurerm_data_factory_pipeline.pipeline.monitor_metrics_after_duration == "00:10:00"
    error_message = "The legacy pipeline spelling must remain accepted."
  }
}

run "kusto_legacy_single_extension" {
  command = plan
  module {
    source = "../modules/databases/data_explorer/kusto_clusters"
  }
  variables {
    base_tags = {}
    settings = {
      name                = "migrationtest"
      sku                 = { name = "Dev(No SLA)_Standard_D11_v2", capacity = 1 }
      language_extensions = { name = "PYTHON", image = "Python3_11_7" }
    }
  }
  assert {
    condition     = one(azurerm_kusto_cluster.kusto.language_extension).name == "PYTHON"
    error_message = "The legacy single-object Kusto extension must remain accepted."
  }
}

run "kusto_current_extension_collection" {
  command = plan
  module {
    source = "../modules/databases/data_explorer/kusto_clusters"
  }
  variables {
    base_tags = {}
    settings = {
      name               = "migrationtest"
      sku                = { name = "Dev(No SLA)_Standard_D11_v2", capacity = 1 }
      language_extension = [{ name = "PYTHON", image = "Python3_11_7" }]
    }
  }
  assert {
    condition     = one(azurerm_kusto_cluster.kusto.language_extension).image == "Python3_11_7"
    error_message = "The current Kusto extension collection must be supported."
  }
}

run "iot_legacy_recommendations_and_disabled_solution" {
  command = plan
  module {
    source = "../modules/iot/security/security_solution"
  }
  variables {
    iothub_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Devices/iotHubs/test"]
    settings = {
      name                    = "migrationtest"
      display_name            = "Migration test"
      enabled                 = false
      recommendations_enabled = { open_ports = false }
    }
  }
  assert {
    condition     = !azurerm_iot_security_solution.securitysolution.enabled && !azurerm_iot_security_solution.securitysolution.recommendations[0].open_ports
    error_message = "Legacy IoT recommendations and enabled=false must be preserved."
  }
}

run "keyvault_contacts_preserve_input_shape" {
  command = plan
  module {
    source = "../modules/security/keyvault"
  }
  variables {
    settings = {
      name     = "migrationtest"
      contacts = { owner = { email = "owner@example.com", name = "Owner", phone = "+123456789" } }
    }
  }
  assert {
    condition     = one(azurerm_key_vault_certificate_contacts.contacts["contacts"].contact).email == "owner@example.com" && one(azurerm_key_vault_certificate_contacts.contacts["contacts"].contact).name == "Owner"
    error_message = "Existing Key Vault contacts must retain their input shape and values."
  }
}

run "keyvault_null_contacts_create_no_resource" {
  command = plan
  module {
    source = "../modules/security/keyvault"
  }
  variables {
    settings = { name = "migrationtest", contacts = null }
  }
  assert {
    condition     = length(azurerm_key_vault_certificate_contacts.contacts) == 0
    error_message = "Null contacts must not create a certificate-contacts resource."
  }
}

run "apim_custom_domain_legacy_remote_certificate" {
  command = plan
  module {
    source = "../modules/apim/api_management_custom_domain"
  }
  variables {
    base_tags         = {}
    api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ApiManagement/service/test"
    remote_objects = {
      keyvault_certificates = { local = { cert = { secret_id = "https://migrationtest.vault.azure.net/secrets/cert" } } }
    }
    settings = {
      gateways = [{ host_name = "api.example.com", key_vault_certificate = { certificate_key = "cert" } }]
    }
  }
  assert {
    condition     = one(azurerm_api_management_custom_domain.apim.gateway).key_vault_certificate_id == "https://migrationtest.vault.azure.net/secrets/cert"
    error_message = "Legacy same-landing-zone certificate lookup must resolve to its secret URI."
  }
}

run "container_app_template_grace_period" {
  command = plan
  module {
    source = "../modules/compute/container_app"
  }
  variables {
    container_app_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.App/managedEnvironments/test"
    diagnostic_profiles          = {}
    combined_diagnostics         = {}
    settings = {
      name          = "migrationtest"
      revision_mode = "Single"
      template = {
        termination_grace_period_seconds = 45
        container = {
          app = {
            name   = "app"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 0.25
            memory = "0.5Gi"
          }
        }
      }
    }
  }
  assert {
    condition     = azurerm_container_app.ca.template[0].termination_grace_period_seconds == 45
    error_message = "The supported template-level grace period must be preserved."
  }
}

run "container_app_legacy_probe_grace_period_rejected" {
  command = plan
  module {
    source = "../modules/compute/container_app"
  }
  variables {
    container_app_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.App/managedEnvironments/test"
    diagnostic_profiles          = {}
    combined_diagnostics         = {}
    settings = {
      name          = "migrationtest"
      revision_mode = "Single"
      template = {
        container = {
          app = {
            name   = "app"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 0.25
            memory = "0.5Gi"
            liveness_probe = {
              port                             = 8080
              transport                        = "TCP"
              termination_grace_period_seconds = 45
            }
          }
        }
      }
    }
  }
  expect_failures = [azurerm_container_app.ca]
}

run "express_route_connection_legacy_internet_security_alias" {
  command = plan
  module {
    source = "../modules/networking/express_route_connection"
  }
  variables {
    client_config                    = { landingzone_key = "local" }
    express_route_gateway_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteGateways/gateway"
    express_route_circuit_peering_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteCircuits/circuit/peerings/AzurePrivatePeering"
    virtual_hub_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualHubs/hub"
    settings = {
      name                     = "migrationtest"
      enable_internet_security = true
    }
  }
  assert {
    condition     = azurerm_express_route_connection.erc.internet_security_enabled
    error_message = "The legacy enable_internet_security setting must map to internet_security_enabled."
  }
}

run "express_route_connection_current_flag_precedence" {
  command = plan
  module {
    source = "../modules/networking/express_route_connection"
  }
  variables {
    client_config                    = { landingzone_key = "local" }
    express_route_gateway_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteGateways/gateway"
    express_route_circuit_peering_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/expressRouteCircuits/circuit/peerings/AzurePrivatePeering"
    virtual_hub_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualHubs/hub"
    settings = {
      name                      = "migrationtest"
      internet_security_enabled = true
      enable_internet_security  = false
    }
  }

  assert {
    condition     = azurerm_express_route_connection.erc.internet_security_enabled
    error_message = "The current internet_security_enabled setting must take precedence over its legacy alias."
  }
}

run "nsg_flow_log_uses_target_resource_id" {
  command = plan
  module {
    source = "../modules/networking/virtual_network/nsg/flow_logs"
  }
  variables {
    client_config     = { landingzone_key = "local" }
    resource_location = "westeurope"
    resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/networkSecurityGroups/test"
    network_watchers  = {}
    diagnostics = {
      diagnostics_destinations = {
        storage = {
          all_regions = {
            westeurope = { storage_account_key = "logs" }
          }
        }
      }
      storage_accounts = {
        logs = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Storage/storageAccounts/logs" }
      }
    }
    settings = {
      name            = "migrationtest-flow"
      storage_account = { storage_account_destination = "all_regions" }
    }
  }
  assert {
    condition     = azurerm_network_watcher_flow_log.flow[0].target_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/networkSecurityGroups/test"
    error_message = "The flow log's target_resource_id must receive the selected network security group ID."
  }
}
