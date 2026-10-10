mock_provider "azapi" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "dns-link" }
  }
}

variables {
  global_settings    = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
  client_config      = { landingzone_key = "local" }
  virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example"
  private_dns        = {}
  inherit_tags       = false
}

run "explicit_null_entry_timeouts_use_module_timeouts" {
  command = plan
  module {
    source = "../modules/networking/private_dns_vnet_link_v1"
  }
  variables {
    settings = {
      timeouts = { create = "30m" }
      private_dns_zones = {
        zone = {
          name     = "link"
          id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/privateDnsZones/example.internal"
          timeouts = null
        }
      }
    }
  }
  assert {
    condition     = azapi_resource.vnet_links["zone"].timeouts.create == "30m"
    error_message = "An explicit null entry timeout must fall back to settings.timeouts."
  }
}

run "entry_timeouts_take_precedence" {
  command = plan
  module {
    source = "../modules/networking/private_dns_vnet_link_v1"
  }
  variables {
    settings = {
      timeouts = { create = "30m" }
      private_dns_zones = {
        zone = {
          name     = "link"
          id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/privateDnsZones/example.internal"
          timeouts = { create = "45m" }
        }
      }
    }
  }
  assert {
    condition     = azapi_resource.vnet_links["zone"].timeouts.create == "45m"
    error_message = "A non-null entry timeout must take precedence over settings.timeouts."
  }
}
