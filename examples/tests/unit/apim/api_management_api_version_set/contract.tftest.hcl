mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-versions" }
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
run "segment_versioning_and_local_parents" {
  command = plan
  module { source = "../modules/apim/api_management_api_version_set" }
  variables {
    settings = { name = "versions", display_name = "Orders", versioning_scheme = "Segment", api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.name == "caf-versions" && azurerm_api_management_api_version_set.resource.api_management_name == "local-apim" && azurerm_api_management_api_version_set.resource.resource_group_name == "local-rg"
    error_message = "Segment versioning must resolve local parents and use the CAF-generated name."
  }
}
run "header_versioning_remote_parents_and_optionals" {
  command = plan
  module { source = "../modules/apim/api_management_api_version_set" }
  variables {
    settings = { name = "versions", display_name = "Orders", versioning_scheme = "Header", version_header_name = "X-Api-Version", description = "Order versions", api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = azurerm_api_management_api_version_set.resource.api_management_name == "remote-apim" && azurerm_api_management_api_version_set.resource.resource_group_name == "remote-rg" && azurerm_api_management_api_version_set.resource.version_header_name == "X-Api-Version" && azurerm_api_management_api_version_set.resource.description == "Order versions" && azurerm_api_management_api_version_set.resource.timeouts.update == "41m"
    error_message = "Header name, description, remote references and timeouts must be preserved."
  }
}
run "query_versioning_direct_names_override_keys" {
  command = plan
  module { source = "../modules/apim/api_management_api_version_set" }
  variables {
    settings = { name = "versions", display_name = "Orders", versioning_scheme = "Query", version_query_name = "api-version", api_management_name = "direct-apim", resource_group_name = "direct-rg", api_management = { key = "missing" }, resource_group = { key = "missing" }, description = null, timeouts = null }
  }
  assert {
    condition     = azurerm_api_management_api_version_set.resource.api_management_name == "direct-apim" && azurerm_api_management_api_version_set.resource.resource_group_name == "direct-rg" && azurerm_api_management_api_version_set.resource.version_query_name == "api-version"
    error_message = "Query versioning and direct-name precedence must work with explicit null optionals."
  }
}
run "reject_unknown_scheme" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_api_version_set" }
  variables {
    settings = { name = "versions", display_name = "Orders", versioning_scheme = "Cookie", api_management_name = "apim", resource_group_name = "rg" }
  }
}
run "header_requires_name" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_api_version_set" }
  variables {
    settings = { name = "versions", display_name = "Orders", versioning_scheme = "Header", api_management_name = "apim", resource_group_name = "rg" }
  }
}
run "query_requires_name" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_api_version_set" }
  variables {
    settings = { name = "versions", display_name = "Orders", versioning_scheme = "Query", api_management_name = "apim", resource_group_name = "rg" }
  }
}
