mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-schema" }
  }
}
variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    resource_groups = {
      local  = { parent = { name = "local-rg" } }
      remote = { parent = { name = "remote-rg" } }
    }
    api_management = {
      local  = { parent = { name = "local-apim" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim" } }
    }
    api_management_api = {
      local  = { parent = { name = "local-api" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/remote-apim/apis/remote-api" } }
    }
  }
}
run "local_names_and_caf_identifier" {
  command = plan
  module { source = "../modules/apim/api_management_api_schema" }
  variables {
    settings = { schema_id = "schema", content_type = "application/vnd.oai.openapi.components+json", components = "{\"schemas\":{}}", api = { key = "parent" }, api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.schema_id == "caf-schema" && output.api_name == "local-api" && azurerm_api_management_api_schema.resource.api_management_name == "local-apim" && azurerm_api_management_api_schema.resource.resource_group_name == "local-rg" && azurerm_api_management_api_schema.resource.components == "{\"schemas\":{}}"
    error_message = "Schema identifiers use CAF; local parent names resolve by key."
  }
}
run "remote_id_only_parents_and_definitions_payload" {
  command = plan
  module { source = "../modules/apim/api_management_api_schema" }
  variables {
    settings = {
      schema_id   = "schema", content_type = "application/vnd.ms-azure-apim.swagger.definitions+json"
      api         = { key = "parent", lz_key = "remote" }, api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }
      definitions = "{\"Order\":{\"type\":\"object\"}}"
      timeouts    = { create = "40m", read = "6m", update = "41m", delete = "42m" }
    }
  }
  assert {
    condition     = output.api_name == "remote-api" && azurerm_api_management_api_schema.resource.api_management_name == "remote-apim" && azurerm_api_management_api_schema.resource.resource_group_name == "remote-rg" && azurerm_api_management_api_schema.resource.definitions == "{\"Order\":{\"type\":\"object\"}}" && azurerm_api_management_api_schema.resource.timeouts.update == "41m"
    error_message = "ID-only remote parents must resolve short names; the definitions payload and timeouts must be forwarded."
  }
}
run "direct_names_override_missing_references" {
  command = plan
  module { source = "../modules/apim/api_management_api_schema" }
  variables {
    settings = {
      schema_id = "schema", content_type = "application/json"
      api_name  = "direct-api", api_management_name = "direct-apim", resource_group_name = "direct-rg"
      api       = { key = "missing" }, api_management = { key = "missing" }, resource_group = { key = "missing" }
      value     = "{\"type\":\"object\"}", components = null, definitions = null, timeouts = null
    }
  }
  assert {
    condition     = output.api_name == "direct-api" && azurerm_api_management_api_schema.resource.api_management_name == "direct-apim" && azurerm_api_management_api_schema.resource.resource_group_name == "direct-rg" && azurerm_api_management_api_schema.resource.value == "{\"type\":\"object\"}"
    error_message = "Explicit names must override missing references and accept null unused payload fields."
  }
}
run "reject_missing_schema_payload" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_api_schema" }
  variables {
    settings = { schema_id = "schema", content_type = "application/vnd.oai.openapi.components+json", api_name = "api", api_management_name = "apim", resource_group_name = "rg" }
  }
}
run "reject_all_null_schema_payloads" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_api_schema" }
  variables {
    settings = { schema_id = "schema", content_type = "application/vnd.oai.openapi.components+json", api_name = "api", api_management_name = "apim", resource_group_name = "rg", value = null, components = null, definitions = null }
  }
}
run "reject_conflicting_schema_payloads" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_api_schema" }
  variables {
    settings = { schema_id = "schema", content_type = "application/json", api_name = "api", api_management_name = "apim", resource_group_name = "rg", value = "{}", components = "{}" }
  }
}
