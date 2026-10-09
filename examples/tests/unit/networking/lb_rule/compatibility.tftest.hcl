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
