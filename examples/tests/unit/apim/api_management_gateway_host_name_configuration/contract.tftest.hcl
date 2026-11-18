mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-hostname" }
  }
}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/local-apim" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim" } }
    }
    api_management_gateway = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/local-apim/gateways/local-gateway" } }
      remote = { parent = { name = "remote-gateway" } }
    }
    api_management_certificate = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/local-apim/certificates/local-cert" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim/certificates/remote-cert" } }
    }
  }
}
run "local_parents_and_http2_default" {
  command = plan
  module { source = "../modules/apim/api_management_gateway_host_name_configuration" }
  variables {
    settings = { name = "hostname", host_name = "api.example.com", api_management = { key = "parent" }, gateway = { key = "parent" }, certificate = { key = "parent" } }
  }
  assert {
    condition     = output.name == "caf-hostname" && output.gateway_name == "local-gateway" && azurerm_api_management_gateway_host_name_configuration.resource.http2_enabled && endswith(azurerm_api_management_gateway_host_name_configuration.resource.certificate_id, "/certificates/local-cert")
    error_message = "Local dependencies, CAF naming and the explicit HTTP/2 default must resolve."
  }
}
run "remote_parents_and_all_protocol_flags" {
  command = plan
  module { source = "../modules/apim/api_management_gateway_host_name_configuration" }
  variables {
    settings = {
      name          = "hostname", host_name = "remote.example.com", api_management = { key = "parent", lz_key = "remote" }, gateway = { key = "parent", lz_key = "remote" }, certificate = { key = "parent", lz_key = "remote" }
      http2_enabled = false, request_client_certificate_enabled = true, tls10_enabled = false, tls11_enabled = false
      timeouts      = { create = "40m", read = "6m", update = "41m", delete = "42m" }
    }
  }
  assert {
    condition     = output.gateway_name == "remote-gateway" && output.host_name == "remote.example.com" && endswith(azurerm_api_management_gateway_host_name_configuration.resource.api_management_id, "/service/remote-apim") && endswith(azurerm_api_management_gateway_host_name_configuration.resource.certificate_id, "/certificates/remote-cert") && !azurerm_api_management_gateway_host_name_configuration.resource.http2_enabled && azurerm_api_management_gateway_host_name_configuration.resource.request_client_certificate_enabled && !azurerm_api_management_gateway_host_name_configuration.resource.tls10_enabled && !azurerm_api_management_gateway_host_name_configuration.resource.tls11_enabled && azurerm_api_management_gateway_host_name_configuration.resource.timeouts.update == "41m"
    error_message = "All remote dependencies, protocol flags, host name and timeouts must pass through."
  }
}
run "direct_arguments_and_explicit_null_default" {
  command = plan
  module { source = "../modules/apim/api_management_gateway_host_name_configuration" }
  variables {
    settings = {
      name              = "hostname", host_name = "direct.example.com"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim"
      gateway_name      = "direct-gateway", certificate_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim/certificates/direct-cert"
      api_management    = { key = "missing" }, gateway = { key = "missing" }, certificate = { key = "missing" }
      http2_enabled     = null, request_client_certificate_enabled = null, tls10_enabled = null, tls11_enabled = null, timeouts = null
    }
  }
  assert {
    condition     = output.gateway_name == "direct-gateway" && azurerm_api_management_gateway_host_name_configuration.resource.http2_enabled && endswith(azurerm_api_management_gateway_host_name_configuration.resource.certificate_id, "/certificates/direct-cert")
    error_message = "Direct arguments must override references and explicit null HTTP/2 must retain the true default."
  }
}
