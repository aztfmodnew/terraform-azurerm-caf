mock_provider "azurerm" {}

run "gateway_api_with_local_keys_and_timeouts" {
  command = plan

  module {
    source = "../modules/apim/api_management_gateway_api"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_management_gateway = {
        local = {
          gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/gateways/gateway-key" }
        }
      }
      api_management_api = {
        local = {
          api = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/api-key" }
        }
      }
    }
    settings = {
      api_management_gateway = {
        key    = "gateway"
        lz_key = null
        id     = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/gateways/gateway-direct"
      }
      api_management_api = {
        key = "api"
        id  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/api-direct"
      }
      timeouts = {
        create = "45m"
        read   = "6m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_gateway_api.apim.gateway_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/gateways/gateway-key" &&
      azurerm_api_management_gateway_api.apim.api_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/apis/api-key" &&
      azurerm_api_management_gateway_api.apim.timeouts.create == "45m" &&
      azurerm_api_management_gateway_api.apim.timeouts.read == "6m" &&
      azurerm_api_management_gateway_api.apim.timeouts.delete == "45m"
    )
    error_message = "Local key references must take precedence over direct IDs and all supported timeouts must be passed."
  }
}

run "gateway_api_with_remote_references_and_local_fallback" {
  command = plan

  module {
    source = "../modules/apim/api_management_gateway_api"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_management_gateway = {
        remote = {
          gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim/gateways/gateway" }
        }
      }
      api_management_api = {
        local = {
          api = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/local-apim/apis/api" }
        }
      }
    }
    settings = {
      api_management_gateway = { key = "gateway", lz_key = "remote" }
      api_management_api     = { key = "api" }
    }
  }

  assert {
    condition = (
      azurerm_api_management_gateway_api.apim.gateway_id == "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim/gateways/gateway" &&
      azurerm_api_management_gateway_api.apim.api_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/local-apim/apis/api"
    )
    error_message = "Remote and local landing-zone references must resolve independently."
  }
}

run "gateway_api_with_direct_ids" {
  command = plan

  module {
    source = "../modules/apim/api_management_gateway_api"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects  = {}
    settings = {
      api_management_gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/direct-rg/providers/Microsoft.ApiManagement/service/direct-apim/gateways/gateway" }
      api_management_api     = { id = "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/direct-rg/providers/Microsoft.ApiManagement/service/direct-apim/apis/api" }
    }
  }

  assert {
    condition = (
      azurerm_api_management_gateway_api.apim.gateway_id == "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/direct-rg/providers/Microsoft.ApiManagement/service/direct-apim/gateways/gateway" &&
      azurerm_api_management_gateway_api.apim.api_id == "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/direct-rg/providers/Microsoft.ApiManagement/service/direct-apim/apis/api"
    )
    error_message = "Direct IDs must be accepted when no keyed objects are supplied."
  }
}
