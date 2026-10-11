mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-gateway" }
  }
}

run "gateway_with_local_reference_and_full_location_data" {
  command = plan

  module {
    source = "../modules/apim/api_management_gateway"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config = { landingzone_key = "local" }
    remote_objects = {
      api_management = {
        local = {
          apim = { id = "/subscriptions/test/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim-key" }
        }
      }
    }
    settings = {
      name = "sample-gateway"
      api_management = {
        key    = "apim"
        lz_key = null
        id     = "/subscriptions/test/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim-direct"
      }
      description = "Regional API Management gateway"
      location_data = {
        name     = "Sydney"
        city     = "Sydney"
        district = "New South Wales"
        region   = "Australia"
      }
      resource_group = { key = "rg1" }
      timeouts = {
        create = "45m"
        read   = "6m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_gateway.apim.name == "example-gateway" &&
      azurerm_api_management_gateway.apim.api_management_id == "/subscriptions/test/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim-key" &&
      azurerm_api_management_gateway.apim.description == "Regional API Management gateway" &&
      azurerm_api_management_gateway.apim.location_data[0].name == "Sydney" &&
      azurerm_api_management_gateway.apim.location_data[0].district == "New South Wales" &&
      azurerm_api_management_gateway.apim.timeouts.update == "45m"
    )
    error_message = "The gateway must use CAF naming, preserve key-reference precedence, and pass all provider options."
  }
}

run "gateway_with_remote_reference" {
  command = plan

  module {
    source = "../modules/apim/api_management_gateway"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config = { landingzone_key = "local" }
    remote_objects = {
      api_management = {
        remote = {
          apim = { id = "/subscriptions/remote/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim" }
        }
      }
    }
    settings = {
      name           = "remote-gateway"
      api_management = { key = "apim", lz_key = "remote" }
      location_data  = { name = "Remote region" }
    }
  }

  assert {
    condition     = azurerm_api_management_gateway.apim.api_management_id == "/subscriptions/remote/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim"
    error_message = "A remote landing-zone key must resolve to the requested API Management service."
  }
}

run "gateway_with_direct_api_management_id" {
  command = plan

  module {
    source = "../modules/apim/api_management_gateway"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config  = { landingzone_key = "local" }
    remote_objects = {}
    settings = {
      name           = "direct-gateway"
      api_management = { id = "/subscriptions/direct/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim" }
      location_data  = { name = "Direct region" }
    }
  }

  assert {
    condition     = azurerm_api_management_gateway.apim.api_management_id == "/subscriptions/direct/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim"
    error_message = "A direct API Management resource ID must remain supported."
  }
}
