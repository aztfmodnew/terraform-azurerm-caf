mock_provider "azurerm" {
  mock_resource "azurerm_resource_group_template_deployment" {
    defaults = {
      output_content = "{\"id\":{\"type\":\"String\",\"value\":\"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-ase\"}}"
    }
  }
  mock_data "azurerm_app_service_environment_v3" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-ase"
      internal_inbound_ip_addresses = ["10.0.0.4"]
    }
  }
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "mock-ase" }
  }
}

run "decode_arm_deployment_output" {
  command = apply
  module {
    source = "../modules/webapps/ase"
  }

  variables {
    name                      = "mock-ase"
    kind                      = "ASEV2"
    zone                      = "1"
    location                  = "westeurope"
    resource_group_name       = "mock-rg"
    subnet_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/ase"
    subnet_name               = "ase"
    internalLoadBalancingMode = null
    tags                      = {}
    base_tags                 = {}
    diagnostic_profiles       = null
    diagnostics               = null
    private_dns = {
      local = {
        zone = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/privateDnsZones/example.test"
        }
      }
    }
    client_config = { landingzone_key = "local" }
    settings = {
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
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
  }
  assert {
    condition     = null_resource.destroy_ase.triggers.resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-ase"
    error_message = "ASE lifecycle must extract the resource ID from the serialized ARM deployment output."
  }
  assert {
    condition     = azurerm_private_dns_a_record.a_records["ase"].private_dns_zone_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/privateDnsZones/example.test"
    error_message = "ASE private DNS records must resolve their zone from the current landing zone when lz_key is null."
  }
}
