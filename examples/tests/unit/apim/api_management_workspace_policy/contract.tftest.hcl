mock_provider "azurerm" {}
mock_provider "azurecaf" {}
run "explicit_null_timeouts_preserve_parent_and_provider_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_policy"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_workspace_policy.resource.timeouts == null && endswith(output.api_management_workspace_id, "/local-team") && azurerm_api_management_workspace_policy.resource.xml_content == var.settings.xml_content
    error_message = "Explicit null must not introduce timeout overrides or change inline policy content."
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
    xml_content              = "<policies><inbound><base /></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>"
    api_management_workspace = { key = "team" }
  }
}
run "local_workspace_and_inline_policy" {
  command = plan
  assert {
    condition     = azurerm_api_management_workspace_policy.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_workspace_policy"
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/local-team") && azurerm_api_management_workspace_policy.resource.xml_content == var.settings.xml_content && azurerm_api_management_workspace_policy.resource.xml_link == null
    error_message = "Inline policy content and the local workspace reference must be preserved."
  }
}
run "remote_workspace_and_linked_policy" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_policy"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace = { key = "team", lz_key = "remote" }
      xml_content              = null
      xml_link                 = "https://example.com/policy.xml"
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/remote-team") && azurerm_api_management_workspace_policy.resource.xml_link == "https://example.com/policy.xml" && var.settings.xml_content == null
    error_message = "Linked policy configuration must resolve the remote workspace without inline content."
  }
}
run "direct_workspace_and_timeouts" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_policy"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/explicit-team"
      api_management_workspace    = { key = "missing" }
      timeouts                    = { create = null, update = "41m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/explicit-team") && azurerm_api_management_workspace_policy.resource.timeouts.create == "30m" && azurerm_api_management_workspace_policy.resource.timeouts.update == "41m"
    error_message = "Direct IDs must override keys; typed defaults and explicit timeouts must pass through."
  }
}
run "reject_two_policy_sources" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_policy"
  }
  variables {
    settings = merge(var.settings, { xml_link = "https://example.com/policy.xml" })
  }
}
run "reject_missing_policy_source" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_policy"
  }
  variables {
    settings = merge(var.settings, { xml_content = null })
  }
}
