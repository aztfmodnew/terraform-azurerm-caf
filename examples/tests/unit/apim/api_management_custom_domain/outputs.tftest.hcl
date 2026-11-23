mock_provider "azurerm" {}

run "all_endpoint_outputs_include_computed_certificate_metadata" {
  command = plan

  module {
    source = "../modules/apim/api_management_custom_domain"
  }

  variables {
    global_settings   = {}
    client_config     = { landingzone_key = "local" }
    api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim"
    settings = {
      developer_portal = { host_name = "developer.example.com", certificate = "developer-certificate" }
      management       = { host_name = "management.example.com", certificate = "management-certificate" }
      portal           = { host_name = "portal.example.com", certificate = "portal-certificate" }
      gateway          = { host_name = "gateway.example.com", certificate = "gateway-certificate", default_ssl_binding = false }
      scm              = { host_name = "scm.example.com", certificate = "scm-certificate" }
    }
  }

  assert {
    condition = (
      one(output.developer_portals).host_name == "developer.example.com" &&
      one(output.managements).host_name == "management.example.com" &&
      one(output.portals).host_name == "portal.example.com" &&
      one(output.gateways).host_name == "gateway.example.com" &&
      one(output.gateways).default_ssl_binding == false &&
      one(output.scms).host_name == "scm.example.com"
    )
    error_message = "Each custom-domain endpoint collection must be available to module consumers."
  }

  assert {
    condition = alltrue(flatten([
      for endpoints in [output.developer_portals, output.managements, output.portals, output.gateways, output.scms] : [
        for field in ["certificate_source", "certificate_status", "expiry", "subject", "thumbprint"] :
        contains(keys(one(endpoints)), field)
      ]
    ]))
    error_message = "Every endpoint output must include the complete computed certificate metadata."
  }
}
