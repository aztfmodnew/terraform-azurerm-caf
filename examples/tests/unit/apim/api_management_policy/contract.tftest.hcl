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
  }
}
run "inline_policy_local_parent" {
  command = plan
  module { source = "../modules/apim/api_management_policy" }
  variables {
    settings = { api_management = { key = "parent" }, xml_content = "<policies><inbound/><backend/><outbound/><on-error/></policies>" }
  }
  assert {
    condition     = endswith(output.api_management_id, "/service/local-apim") && azurerm_api_management_policy.resource.xml_content == "<policies><inbound/><backend/><outbound/><on-error/></policies>"
    error_message = "Inline service policy and local APIM reference must be preserved."
  }
}
run "linked_policy_remote_parent_and_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_policy" }
  variables {
    settings = { api_management = { key = "parent", lz_key = "remote" }, xml_link = "https://example.com/policy.xml", timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = endswith(output.api_management_id, "/service/remote-apim") && azurerm_api_management_policy.resource.xml_link == "https://example.com/policy.xml" && azurerm_api_management_policy.resource.timeouts.update == "41m"
    error_message = "Linked policies must retain the URL, remote APIM and supported timeouts."
  }
}
run "direct_id_and_null_link" {
  command = plan
  module { source = "../modules/apim/api_management_policy" }
  variables {
    settings = { api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/direct-apim", api_management = { key = "missing" }, xml_content = "<policies/>", xml_link = null, timeouts = null }
  }
  assert {
    condition     = endswith(output.api_management_id, "/service/direct-apim")
    error_message = "Direct APIM ID must override a missing reference with explicit null optionals."
  }
}
run "reject_missing_policy_source" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_policy" }
  variables {
    settings = { api_management = { key = "parent" } }
  }
}
run "reject_conflicting_policy_sources" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_policy" }
  variables {
    settings = { api_management = { key = "parent" }, xml_content = "<policies/>", xml_link = "https://example.com/policy.xml" }
  }
}
