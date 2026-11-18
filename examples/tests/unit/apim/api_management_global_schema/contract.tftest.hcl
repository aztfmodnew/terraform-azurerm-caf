mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-global-schema" }
  }
}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { parent = { name = "local-apim" } }
      remote = { parent = { name = "remote-apim" } }
    }
    resource_groups = {
      local  = { parent = { name = "local-rg" } }
      remote = { parent = { name = "remote-rg" } }
    }
  }
}
run "local_parents_and_json_schema" {
  command = plan
  module { source = "../modules/apim/api_management_global_schema" }
  variables {
    settings = { schema_id = "schema", type = "json", value = "{\"type\":\"object\"}", api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.schema_id == "caf-global-schema" && output.type == "json" && azurerm_api_management_global_schema.resource.api_management_name == "local-apim" && azurerm_api_management_global_schema.resource.resource_group_name == "local-rg"
    error_message = "JSON global schemas must use CAF identifiers and local parent references."
  }
}
run "remote_parents_xml_and_optionals" {
  command = plan
  module { source = "../modules/apim/api_management_global_schema" }
  variables {
    settings = { schema_id = "schema", type = "xml", value = "<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\"/>", description = "Shared XML schema", api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = output.type == "xml" && azurerm_api_management_global_schema.resource.api_management_name == "remote-apim" && azurerm_api_management_global_schema.resource.resource_group_name == "remote-rg" && azurerm_api_management_global_schema.resource.description == "Shared XML schema" && azurerm_api_management_global_schema.resource.value == "<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\"/>" && azurerm_api_management_global_schema.resource.timeouts.update == "41m"
    error_message = "Remote parents, XML payload, description and timeouts must pass through."
  }
}
run "direct_names_and_null_optionals" {
  command = plan
  module { source = "../modules/apim/api_management_global_schema" }
  variables {
    settings = { schema_id = "schema", type = "json", value = "{}", api_management_name = "direct-apim", resource_group_name = "direct-rg", api_management = { key = "missing" }, resource_group = { key = "missing" }, description = null, timeouts = null }
  }
  assert {
    condition     = azurerm_api_management_global_schema.resource.api_management_name == "direct-apim" && azurerm_api_management_global_schema.resource.resource_group_name == "direct-rg"
    error_message = "Direct names must override missing references and accept null optionals."
  }
}
