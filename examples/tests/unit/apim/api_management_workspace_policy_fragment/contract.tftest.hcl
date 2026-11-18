mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-example" }
  }
}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_policy_fragment"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_workspace_policy_fragment.resource.timeouts == null && endswith(output.api_management_workspace_id, "/local-team") && output.xml_format == "xml"
    error_message = "Explicit null must not introduce timeout overrides or change the XML format default."
  }
}
variables {
  client_config = { landingzone_key = "local" }
  remote_objects = {
    api_management_workspace = {
      local  = { team = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/local-team" } }
      remote = { team = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/remote-team" } }
    }
  }
  settings = {
    name                     = "example"
    xml_content              = "<fragment><set-header name=\"X-Team\" exists-action=\"override\"><value>example</value></set-header></fragment>"
    api_management_workspace = { key = "team" }
  }
}
run "local_workspace_xml_default_and_caf_fallback" {
  command = plan
  assert {
    condition     = azurerm_api_management_workspace_policy_fragment.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_workspace_policy_fragment"
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/local-team") && output.name == "caf-example" && output.xml_format == "xml" && azurecaf_name.resource.resource_type == "azurerm_api_management_policy_fragment"
    error_message = "Local workspace, XML default and the documented service-level CAF fallback must be preserved."
  }
}
run "remote_workspace_rawxml_and_description" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_policy_fragment"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace = { key = "team", lz_key = "remote" }
      xml_format               = "rawxml"
      description              = "Shared team header"
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/remote-team") && output.xml_format == "rawxml" && azurerm_api_management_workspace_policy_fragment.resource.description == "Shared team header"
    error_message = "Remote workspace and all optional fragment attributes must pass through."
  }
}
run "direct_workspace_and_explicit_null_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_policy_fragment"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/explicit-team"
      api_management_workspace    = { key = "missing" }
      xml_format                  = null
      timeouts                    = { create = null, update = "41m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/explicit-team") && output.xml_format == "xml" && azurerm_api_management_workspace_policy_fragment.resource.timeouts.create == "30m" && azurerm_api_management_workspace_policy_fragment.resource.timeouts.update == "41m"
    error_message = "Direct workspace ID must win and explicit nulls must use typed defaults."
  }
}
