mock_provider "azurerm" {}
mock_provider "azurecaf" {}
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
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim/gateways/remote-gateway" } }
    }
    api_management_certificate = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/local-apim/certificates/local-cert" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/remote-apim/certificates/remote-cert" } }
    }
  }
}
run "local_id_only_parents_resolve_names" {
  command = plan
  module { source = "../modules/apim/api_management_gateway_certificate_authority" }
  variables {
    settings = { api_management = { key = "parent" }, gateway = { key = "parent" }, certificate = { key = "parent" } }
  }
  assert {
    condition     = output.gateway_name == "local-gateway" && output.certificate_name == "local-cert" && endswith(azurerm_api_management_gateway_certificate_authority.resource.api_management_id, "/service/local-apim")
    error_message = "Existing gateway/certificate modules expose id; names must be extracted from those IDs."
  }
}
run "remote_parents_trust_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_gateway_certificate_authority" }
  variables {
    settings = { api_management = { key = "parent", lz_key = "remote" }, gateway = { key = "parent", lz_key = "remote" }, certificate = { key = "parent", lz_key = "remote" }, is_trusted = true, timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = output.gateway_name == "remote-gateway" && output.certificate_name == "remote-cert" && endswith(azurerm_api_management_gateway_certificate_authority.resource.api_management_id, "/service/remote-apim") && azurerm_api_management_gateway_certificate_authority.resource.is_trusted && azurerm_api_management_gateway_certificate_authority.resource.timeouts.update == "41m"
    error_message = "Remote parents, explicit trust and all supported timeouts must pass through."
  }
}
run "direct_values_override_missing_keys" {
  command = plan
  module { source = "../modules/apim/api_management_gateway_certificate_authority" }
  variables {
    settings = { api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim", gateway_name = "direct-gateway", certificate_name = "direct-cert", api_management = { key = "missing" }, gateway = { key = "missing" }, certificate = { key = "missing" }, is_trusted = false, timeouts = null }
  }
  assert {
    condition     = output.gateway_name == "direct-gateway" && output.certificate_name == "direct-cert" && !azurerm_api_management_gateway_certificate_authority.resource.is_trusted
    error_message = "Direct parent arguments and explicit false trust must be preserved."
  }
}
