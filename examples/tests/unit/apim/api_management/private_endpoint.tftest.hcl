mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "private-apim" }
  }
}

variables {
  base_tags       = false
  client_config   = { landingzone_key = "local" }
  global_settings = { prefixes = [], suffixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
  location        = "westeurope"
  resource_group = {
    name     = "apim"
    location = "westeurope"
    tags     = {}
  }
  resource_group_name = "apim"
  resource_groups = {
    local = {
      networking = {
        name     = "networking"
        location = "westeurope"
      }
    }
  }
  vnets = {
    local = {
      apim = {
        subnets = {
          private_endpoints = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/networking/providers/Microsoft.Network/virtualNetworks/apim/subnets/private-endpoints"
          }
        }
      }
    }
  }
  private_dns = {
    local = {
      apim = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/networking/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
      }
    }
  }
}

run "creates_gateway_private_endpoint_with_dns" {
  command = plan

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    private_endpoints = {
      gateway = {
        name               = "apim-gateway"
        resource_group_key = "networking"
        vnet_key           = "apim"
        subnet_key         = "private_endpoints"
        private_service_connection = {
          name                 = "apim-gateway"
          is_manual_connection = false
          subresource_names    = ["incorrect"]
        }
        private_dns = {
          zone_group_name = "apim-gateway"
          keys            = ["apim"]
        }
      }
    }
    settings = {
      name                          = "private-apim"
      publisher_name                = "Private API"
      publisher_email               = "owner@example.com"
      sku_name                      = "Standard_1"
      public_network_access_enabled = false
    }
  }

  assert {
    condition = (
      output.private_endpoints["gateway"].private_service_connection[0].subresource_names[0] == "Gateway" &&
      output.private_endpoints["gateway"].private_dns_zone_group[0].private_dns_zone_ids[0] == var.private_dns.local.apim.id &&
      azurerm_api_management.apim.public_network_access_enabled == false &&
      azurerm_api_management.apim.virtual_network_type == "None"
    )
    error_message = "APIM private endpoints must target Gateway, resolve private DNS, and leave VNet injection unchanged."
  }
}

run "supports_direct_subnet_and_dns_zone_ids" {
  command = plan

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    private_endpoints = {
      gateway = {
        name      = "apim-direct"
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/networking/providers/Microsoft.Network/virtualNetworks/apim/subnets/direct"
        private_service_connection = {
          name                 = "apim-direct"
          is_manual_connection = false
        }
        private_dns = {
          ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/networking/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"]
        }
      }
    }
    settings = {
      name            = "direct-apim"
      publisher_name  = "Private API"
      publisher_email = "owner@example.com"
      sku_name        = "Developer_1"
    }
  }

  assert {
    condition = (
      output.private_endpoints["gateway"].private_service_connection[0].subresource_names == tolist(["Gateway"]) &&
      length(output.private_endpoints["gateway"].private_dns_zone_group[0].private_dns_zone_ids) == 1 &&
      azurerm_api_management.apim.public_network_access_enabled
    )
    error_message = "Direct references must remain backward compatible and public access must default to enabled for the initial endpoint deployment."
  }
}

run "rejects_private_endpoint_for_consumption_sku" {
  command         = plan
  expect_failures = [azurerm_api_management.apim]

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    private_endpoints = {
      gateway = {
        name      = "consumption-apim"
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/networking/providers/Microsoft.Network/virtualNetworks/apim/subnets/private-endpoints"
        private_service_connection = {
          name                 = "consumption-apim"
          is_manual_connection = false
        }
      }
    }
    settings = {
      name            = "consumption-apim"
      publisher_name  = "Private API"
      publisher_email = "owner@example.com"
      sku_name        = "Consumption_0"
    }
  }
}

run "allows_consumption_sku_without_private_endpoint" {
  command = plan

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    private_endpoints = {}
    settings = {
      name            = "consumption-apim"
      publisher_name  = "Public API"
      publisher_email = "owner@example.com"
      sku_name        = "Consumption_0"
    }
  }

  assert {
    condition     = azurerm_api_management.apim.sku_name == "Consumption_0" && length(output.private_endpoints) == 0
    error_message = "Consumption SKUs without private endpoints must remain supported."
  }
}
