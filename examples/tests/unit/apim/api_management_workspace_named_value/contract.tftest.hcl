mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-example" }
  }
}
variables {
  client_config = { landingzone_key = "local" }
  remote_objects = {
    api_management_workspace = {
      local  = { team = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/local-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/local-team" } }
      remote = { team = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/remote-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/remote-team" } }
    }
    keyvaults = {
      remote = { vault = { vault_uri = "https://remote-vault.vault.azure.net/" } }
    }
    managed_identities = {
      remote = { identity = { client_id = "00000000-0000-0000-0000-000000000002" } }
    }
  }
  settings = {
    name                     = "example"
    display_name             = "backend-endpoint"
    value                    = "https://example.com"
    tags                     = ["backend", "team"]
    api_management_workspace = { key = "team" }
  }
}
run "literal_value_labels_and_caf_fallback" {
  command = plan
  assert {
    condition     = azurerm_api_management_workspace_named_value.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/local-team") && output.name == "caf-example" && output.display_name == "backend-endpoint" && !output.secret && toset(azurerm_api_management_workspace_named_value.resource.tags) == toset(["backend", "team"]) && azurecaf_name.resource.resource_type == "azurerm_api_management_named_value"
    error_message = "Literal values must preserve list labels, policy identifiers, false secret default and the documented CAF fallback."
  }
}
run "remote_workspace_vault_and_identity" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace = { key = "team", lz_key = "remote" }
      value                    = null
      secret                   = true
      value_from_key_vault = {
        key_vault        = { key = "vault", lz_key = "remote" }
        managed_identity = { key = "identity", lz_key = "remote" }
        secret_name      = "backend-token"
      }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/remote-team") && one(azurerm_api_management_workspace_named_value.resource.value_from_key_vault).secret_id == "https://remote-vault.vault.azure.net/secrets/backend-token" && one(azurerm_api_management_workspace_named_value.resource.value_from_key_vault).identity_client_id == "00000000-0000-0000-0000-000000000002"
    error_message = "Workspace, vault and managed identity must resolve across landing zones."
  }
}
run "direct_dependencies_override_keys" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/explicit-team"
      api_management_workspace    = { key = "missing" }
      value                       = null
      secret                      = true
      timeouts                    = { update = "41m" }
      value_from_key_vault = {
        secret_id          = "https://explicit-vault.vault.azure.net/secrets/backend-token"
        identity_client_id = "00000000-0000-0000-0000-000000000003"
        key_vault          = { key = "missing" }
        managed_identity   = { key = "missing" }
      }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/explicit-team") && one(azurerm_api_management_workspace_named_value.resource.value_from_key_vault).secret_id == "https://explicit-vault.vault.azure.net/secrets/backend-token" && one(azurerm_api_management_workspace_named_value.resource.value_from_key_vault).identity_client_id == "00000000-0000-0000-0000-000000000003" && azurerm_api_management_workspace_named_value.resource.timeouts.update == "41m"
    error_message = "Explicit dependency values must win and timeouts must pass through."
  }
}
run "explicit_null_secret_and_timeouts_use_defaults" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, { secret = null, timeouts = null })
  }
  assert {
    condition     = !output.secret && azurerm_api_management_workspace_named_value.resource.timeouts == null
    error_message = "Explicit null must retain the false secret default without introducing a provider timeout override."
  }
}
run "key_vault_defaults_to_system_identity" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, {
      value                = null
      secret               = true
      value_from_key_vault = { secret_id = "https://explicit-vault.vault.azure.net/secrets/backend-token" }
    })
  }
  assert {
    condition     = one(azurerm_api_management_workspace_named_value.resource.value_from_key_vault).identity_client_id == null
    error_message = "Omitting identity selection must retain APIM's system identity behavior."
  }
}
run "reject_two_value_sources" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, {
      secret               = true
      value_from_key_vault = { secret_id = "https://explicit-vault.vault.azure.net/secrets/backend-token" }
    })
  }
}
run "reject_key_vault_without_secret_flag" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, {
      value                = null
      value_from_key_vault = { secret_id = "https://explicit-vault.vault.azure.net/secrets/backend-token" }
    })
  }
}
run "reject_key_vault_without_secret_reference" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_named_value"
  }
  variables {
    settings = merge(var.settings, { value = null, secret = true, value_from_key_vault = {} })
  }
}
