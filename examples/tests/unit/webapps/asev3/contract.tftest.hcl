mock_provider "azurerm" {
  mock_resource "azurerm_app_service_environment_v3" {
    override_during = plan
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-asev3"
      internal_inbound_ip_addresses = ["10.0.0.5"]
    }
  }
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "mock-asev3" }
  }
}

run "private_dns_zone_id_uses_current_landing_zone" {
  command = plan
  module {
    source = "../modules/webapps/asev3"
  }
  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config = { landingzone_key = "local" }
    settings = {
      name = "mock-asev3"
      private_dns_records = {
        a_records = {
          ase = {
            name            = ""
            private_dns_key = "zone"
            lz_key          = null
            ttl             = 60
          }
        }
      }
    }
    base_tags           = false
    subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/ase"
    location            = "westeurope"
    resource_group_name = "mock-rg"
    resource_group = {
      name     = "mock-rg"
      location = "westeurope"
      tags     = {}
    }
    private_dns = {
      local = {
        zone = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/privateDnsZones/example.test"
        }
      }
    }
    diagnostic_profiles = null
    diagnostics         = null
  }
  assert {
    condition     = azurerm_private_dns_a_record.a_records["ase"].private_dns_zone_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/privateDnsZones/example.test"
    error_message = "ASEv3 private DNS records must resolve their zone from the current landing zone when lz_key is null."
  }
}
