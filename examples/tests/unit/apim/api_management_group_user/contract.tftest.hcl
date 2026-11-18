mock_provider "azurerm" {}
mock_provider "azurecaf" {}
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
    api_management_group = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/groups/local-group" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/groups/remote-group" } }
    }
    api_management_user = {
      local  = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/users/local-user" } }
      remote = { parent = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/users/remote-user" } }
    }
  }
}
run "local_id_only_parents_resolve_logical_identifiers" {
  command = plan
  module { source = "../modules/apim/api_management_group_user" }
  variables {
    settings = { user = { key = "parent" }, group = { key = "parent" }, api_management = { key = "parent" }, resource_group = { key = "parent" } }
  }
  assert {
    condition     = output.group_name == "local-group" && output.user_id == "local-user" && azurerm_api_management_group_user.resource.api_management_name == "local-apim" && azurerm_api_management_group_user.resource.resource_group_name == "local-rg"
    error_message = "Group and user ARM IDs must become logical identifiers."
  }
}
run "remote_references_and_supported_timeouts" {
  command = plan
  module { source = "../modules/apim/api_management_group_user" }
  variables {
    settings = { user = { key = "parent", lz_key = "remote" }, group = { key = "parent", lz_key = "remote" }, api_management = { key = "parent", lz_key = "remote" }, resource_group = { key = "parent", lz_key = "remote" }, timeouts = { create = "40m", read = "6m", delete = "42m" } }
  }
  assert {
    condition     = output.group_name == "remote-group" && output.user_id == "remote-user" && azurerm_api_management_group_user.resource.api_management_name == "remote-apim" && azurerm_api_management_group_user.resource.resource_group_name == "remote-rg" && azurerm_api_management_group_user.resource.timeouts.delete == "42m"
    error_message = "All cross-landing-zone references and immutable membership timeouts must resolve."
  }
}
run "direct_arguments_override_missing_keys" {
  command = plan
  module { source = "../modules/apim/api_management_group_user" }
  variables {
    settings = {
      user_id    = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/users/direct-user"
      group_name = "direct-group", api_management_name = "direct-apim", resource_group_name = "direct-rg"
      user       = { key = "missing" }, group = { key = "missing" }, api_management = { key = "missing" }, resource_group = { key = "missing" }, timeouts = null
    }
  }
  assert {
    condition     = output.group_name == "direct-group" && output.user_id == "direct-user" && azurerm_api_management_group_user.resource.api_management_name == "direct-apim" && azurerm_api_management_group_user.resource.resource_group_name == "direct-rg"
    error_message = "Direct user ID and parent names must take precedence over missing references."
  }
}
run "direct_logical_user_id_overrides_alias_id_and_key" {
  command = plan
  module { source = "../modules/apim/api_management_group_user" }
  variables {
    settings = {
      user_id = "direct_user-01"
      user = {
        id  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/users/ignored-user"
        key = "parent"
      }
      group_name = "direct-group", api_management_name = "direct-apim", resource_group_name = "direct-rg"
    }
  }
  assert {
    condition     = output.user_id == "direct_user-01"
    error_message = "A logical direct user identifier must remain unchanged and override alias ID and key."
  }
}
run "alias_user_arm_id_overrides_key" {
  command = plan
  module { source = "../modules/apim/api_management_group_user" }
  variables {
    settings = {
      user = {
        id  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/users/alias-user"
        key = "parent"
      }
      group_name = "direct-group", api_management_name = "direct-apim", resource_group_name = "direct-rg"
    }
  }
  assert {
    condition     = output.user_id == "alias-user"
    error_message = "An alias user ARM ID must normalize to the logical identifier before provider validation and override the key."
  }
}
