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
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, { timeouts = null })
  }
  assert {
    condition     = azurerm_api_management_workspace_certificate.resource.timeouts == null && endswith(output.api_management_workspace_id, "/local-team") && azurerm_api_management_workspace_certificate.resource.key_vault_secret_id == var.settings.key_vault_secret_id
    error_message = "Explicit null must not introduce timeout overrides or change the certificate source."
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
      local  = { vault = { vault_uri = "https://local-vault.vault.azure.net/" } }
      remote = { vault = { vault_uri = "https://remote-vault.vault.azure.net/" } }
    }
    managed_identities = {
      local  = { identity = { client_id = "00000000-0000-0000-0000-000000000001" } }
      remote = { identity = { client_id = "00000000-0000-0000-0000-000000000002" } }
    }
    keyvault_certificates = {
      local = { certificate = { secret_id = "https://local-vault.vault.azure.net/secrets/imported-certificate/00000000000000000000000000000001" } }
    }
    keyvault_certificate_requests = {
      remote = { certificate = { secret_id = "https://remote-vault.vault.azure.net/secrets/generated-certificate/00000000000000000000000000000002" } }
    }
  }
  settings = {
    name                     = "example"
    key_vault_secret_id      = "https://local-vault.vault.azure.net/secrets/certificate"
    api_management_workspace = { key = "team" }
  }
}
run "local_workspace_system_identity_and_caf_fallback" {
  command = plan
  assert {
    condition     = azurerm_api_management_workspace_certificate.resource.timeouts == null
    error_message = "Omitted timeouts must leave the provider's documented defaults in control."
  }
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/local-team") && output.name == "caf-example" && azurecaf_name.resource.resource_type == "azurerm_api_management_certificate" && azurerm_api_management_workspace_certificate.resource.user_assigned_identity_client_id == null
    error_message = "Local workspace, service-level CAF fallback and system identity default must be preserved."
  }
}
run "remote_workspace_vault_and_identity" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace = { key = "team", lz_key = "remote" }
      key_vault_secret_id      = null
      key_vault                = { key = "vault", lz_key = "remote" }
      secret_name              = "certificate"
      managed_identity         = { key = "identity", lz_key = "remote" }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/remote-team") && azurerm_api_management_workspace_certificate.resource.key_vault_secret_id == "https://remote-vault.vault.azure.net/secrets/certificate" && azurerm_api_management_workspace_certificate.resource.user_assigned_identity_client_id == "00000000-0000-0000-0000-000000000002"
    error_message = "All dependency references must respect lz_key and identities must resolve client IDs."
  }
}
run "direct_values_override_missing_keys" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      api_management_workspace_id      = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/explicit-rg/providers/Microsoft.ApiManagement/service/gateway/workspaces/explicit-team"
      api_management_workspace         = { key = "missing" }
      key_vault                        = { key = "missing" }
      managed_identity                 = { key = "missing" }
      user_assigned_identity_client_id = "00000000-0000-0000-0000-000000000003"
      timeouts                         = { update = "41m" }
    })
  }
  assert {
    condition     = endswith(output.api_management_workspace_id, "/explicit-team") && azurerm_api_management_workspace_certificate.resource.key_vault_secret_id == var.settings.key_vault_secret_id && azurerm_api_management_workspace_certificate.resource.user_assigned_identity_client_id == "00000000-0000-0000-0000-000000000003" && azurerm_api_management_workspace_certificate.resource.timeouts.update == "41m"
    error_message = "Explicit workspace, URI and client ID must override missing references."
  }
}
run "inline_certificate_and_password" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      key_vault_secret_id     = null
      certificate_data_base64 = "bW9jay1wa2NzMTItZml4dHVyZQ=="
      password                = "mock-only-not-a-credential"
    })
  }
  assert {
    condition     = azurerm_api_management_workspace_certificate.resource.key_vault_secret_id == null && azurerm_api_management_workspace_certificate.resource.certificate_data_base64 == "bW9jay1wa2NzMTItZml4dHVyZQ=="
    error_message = "Inline certificate bytes must pass through without introducing a Key Vault dependency."
  }
}
run "local_imported_certificate_reference" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      key_vault_secret_id = null
      key_vault_secret    = { certificate_key = "certificate" }
    })
  }
  assert {
    condition     = azurerm_api_management_workspace_certificate.resource.key_vault_secret_id == "https://local-vault.vault.azure.net/secrets/imported-certificate/00000000000000000000000000000001"
    error_message = "Imported certificates must resolve their backing secret URI, not a certificate ARM ID."
  }
}
run "remote_generated_certificate_reference" {
  command = plan
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      key_vault_secret_id = null
      key_vault_secret    = { certificate_request_key = "certificate", lz_key = "remote" }
    })
  }
  assert {
    condition     = azurerm_api_management_workspace_certificate.resource.key_vault_secret_id == "https://remote-vault.vault.azure.net/secrets/generated-certificate/00000000000000000000000000000002"
    error_message = "Generated certificate requests must resolve a remote backing secret URI."
  }
}
run "reject_ambiguous_certificate_reference" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      key_vault_secret_id = null
      key_vault_secret    = { certificate_key = "certificate", certificate_request_key = "certificate" }
    })
  }
}
run "reject_two_certificate_sources" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, { certificate_data_base64 = "bW9jaw==" })
  }
}
run "reject_password_without_inline_data" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, { password = "mock-only-not-a-credential" })
  }
}
run "reject_identity_for_inline_certificate" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_workspace_certificate"
  }
  variables {
    settings = merge(var.settings, {
      key_vault_secret_id              = null
      certificate_data_base64          = "bW9jay1wa2NzMTItZml4dHVyZQ=="
      user_assigned_identity_client_id = "00000000-0000-0000-0000-000000000003"
    })
  }
}
