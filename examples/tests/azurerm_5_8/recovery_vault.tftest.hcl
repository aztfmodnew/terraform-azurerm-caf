mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    clean_input   = true
    passthrough   = true
    use_slug      = false
  }
  client_config = { landingzone_key = "local" }
  resource_group = {
    name     = "migrationtest"
    location = "westeurope"
    tags     = {}
  }
  base_tags         = false
  private_endpoints = {}
  vnets             = {}
  remote_objects    = {}
  diagnostics       = { diagnostics_definition = {} }
}

run "omitted_soft_delete_is_supported" {
  command = plan
  module {
    source = "../modules/recovery_vault"
  }
  variables {
    settings = { name = "migrationtest" }
  }
  assert {
    condition     = output.soft_delete_enabled
    error_message = "The legacy compatibility output must remain true."
  }
}

run "legacy_true_is_supported" {
  command = plan
  module {
    source = "../modules/recovery_vault"
  }
  variables {
    settings = { name = "migrationtest", soft_delete_enabled = true }
  }
}

run "legacy_false_is_rejected" {
  command = plan
  module {
    source = "../modules/recovery_vault"
  }
  variables {
    settings = { name = "migrationtest", soft_delete_enabled = false }
  }
  expect_failures = [azurerm_recovery_services_vault.asr]
}
