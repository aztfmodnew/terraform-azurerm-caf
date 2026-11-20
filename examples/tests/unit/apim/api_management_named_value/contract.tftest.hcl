mock_provider "azurerm" {}

override_resource {
  target          = azurecaf_name.named_value
  override_during = plan
  values          = { result = "apimnv-backend-endpoint" }
}

variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { gateway = { name = "local-apim" } }
      remote = { gateway = { name = "remote-apim" } }
    }
    resource_groups = {
      local  = { gateway = { name = "local-rg" } }
      remote = { gateway = { name = "remote-rg" } }
    }
    keyvaults = {
      local  = { gateway = { vault_uri = "https://local-vault.vault.azure.net/" } }
      remote = { gateway = { vault_uri = "https://remote-vault.vault.azure.net/" } }
    }
    managed_identities = {
      local  = { gateway = { client_id = "00000000-0000-0000-0000-000000000001" } }
      remote = { gateway = { client_id = "00000000-0000-0000-0000-000000000002" } }
    }
  }
}

run "literal_value_and_local_references" {
  command = plan
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-endpoint"
      display_name   = "backend-endpoint"
      value          = "https://example.com"
      tags           = ["gateway"]
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
    }
  }
  assert {
    condition = (
      azurerm_api_management_named_value.named_value.name == "apimnv-backend-endpoint" &&
      output.display_name == "backend-endpoint" &&
      azurerm_api_management_named_value.named_value.value == "https://example.com" &&
      azurerm_api_management_named_value.named_value.api_management_name == "local-apim" &&
      azurerm_api_management_named_value.named_value.resource_group_name == "local-rg" &&
      !azurerm_api_management_named_value.named_value.secret &&
      toset(azurerm_api_management_named_value.named_value.tags) == toset(["gateway"])
    )
    error_message = "Literal values must keep policy display names and labels, resolve local references, and default secret to false."
  }
}

run "explicit_null_secret_uses_module_default" {
  command = plan
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name                = "backend-endpoint"
      display_name        = "backend-endpoint"
      value               = "https://example.com"
      secret              = null
      api_management      = { name = "explicit-apim" }
      resource_group_name = "explicit-rg"
    }
  }
  assert {
    condition     = !azurerm_api_management_named_value.named_value.secret
    error_message = "Explicit null must use the module's false secret default."
  }
}

run "key_vault_local_reference_and_system_identity" {
  command = plan
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-token"
      display_name   = "backend-token"
      secret         = true
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
      value_from_key_vault = {
        key_vault   = { key = "gateway" }
        secret_name = "backend-token"
      }
    }
  }
  assert {
    condition = (
      one(azurerm_api_management_named_value.named_value.value_from_key_vault).secret_id == "https://local-vault.vault.azure.net/secrets/backend-token" &&
      one(azurerm_api_management_named_value.named_value.value_from_key_vault).identity_client_id == null &&
      azurerm_api_management_named_value.named_value.value == null
    )
    error_message = "Local Key Vault references must use versionless URIs and preserve the system identity default without reading secret values."
  }
}

run "key_vault_with_local_user_assigned_identity" {
  command = plan
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-token"
      display_name   = "backend-token"
      secret         = true
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
      value_from_key_vault = {
        secret_id        = "https://local-vault.vault.azure.net/secrets/backend-token"
        managed_identity = { key = "gateway" }
      }
    }
  }
  assert {
    condition     = one(azurerm_api_management_named_value.named_value.value_from_key_vault).identity_client_id == "00000000-0000-0000-0000-000000000001"
    error_message = "A local managed identity reference must resolve its client ID, not its ARM or principal ID."
  }
}

run "key_vault_and_identity_remote_references" {
  command = plan
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-token"
      display_name   = "backend-token"
      secret         = true
      api_management = { key = "gateway", lz_key = "remote" }
      resource_group = { key = "gateway", lz_key = "remote" }
      value_from_key_vault = {
        key_vault        = { key = "gateway", lz_key = "remote" }
        secret_name      = "backend-token"
        managed_identity = { key = "gateway", lz_key = "remote" }
      }
    }
  }
  assert {
    condition = (
      azurerm_api_management_named_value.named_value.api_management_name == "remote-apim" &&
      azurerm_api_management_named_value.named_value.resource_group_name == "remote-rg" &&
      one(azurerm_api_management_named_value.named_value.value_from_key_vault).secret_id == "https://remote-vault.vault.azure.net/secrets/backend-token" &&
      one(azurerm_api_management_named_value.named_value.value_from_key_vault).identity_client_id == "00000000-0000-0000-0000-000000000002"
    )
    error_message = "Cross-landing-zone references must resolve the requested APIM, resource group, vault, and identity client ID."
  }
}

run "explicit_values_override_references" {
  command = plan
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name                = "backend-token"
      display_name        = "backend-token"
      secret              = true
      api_management      = { name = "explicit-apim", key = "missing" }
      resource_group_name = "explicit-rg"
      resource_group      = { key = "missing" }
      value_from_key_vault = {
        secret_id          = "https://explicit-vault.vault.azure.net/secrets/backend-token"
        key_vault          = { key = "missing" }
        secret_name        = "ignored"
        identity_client_id = "00000000-0000-0000-0000-000000000003"
        managed_identity   = { key = "missing" }
      }
      timeouts = { create = "40m", read = "6m", update = "40m", delete = "40m" }
    }
  }
  assert {
    condition = (
      azurerm_api_management_named_value.named_value.api_management_name == "explicit-apim" &&
      azurerm_api_management_named_value.named_value.resource_group_name == "explicit-rg" &&
      one(azurerm_api_management_named_value.named_value.value_from_key_vault).secret_id == "https://explicit-vault.vault.azure.net/secrets/backend-token" &&
      one(azurerm_api_management_named_value.named_value.value_from_key_vault).identity_client_id == "00000000-0000-0000-0000-000000000003" &&
      azurerm_api_management_named_value.named_value.timeouts.update == "40m"
    )
    error_message = "Explicit names, secret URIs and identity client IDs must take precedence, and timeouts must pass through."
  }
}

run "key_vault_requires_secret_flag" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-token"
      display_name   = "backend-token"
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
      value_from_key_vault = {
        secret_id = "https://local-vault.vault.azure.net/secrets/backend-token"
      }
    }
  }
}

run "key_vault_requires_a_secret_source" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name                 = "backend-token"
      display_name         = "backend-token"
      secret               = true
      api_management       = { key = "gateway" }
      resource_group       = { key = "gateway" }
      value_from_key_vault = {}
    }
  }
}

run "reject_two_value_sources" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-token"
      display_name   = "backend-token"
      value          = "https://example.com"
      secret         = true
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
      value_from_key_vault = {
        secret_id = "https://local-vault.vault.azure.net/secrets/backend-token"
      }
    }
  }
}

run "reject_missing_value_source" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_named_value"
  }
  variables {
    settings = {
      name           = "backend-token"
      display_name   = "backend-token"
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
    }
  }
}
