mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {
    defaults = {
      id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.KeyVault/vaults/migrationtest"
      vault_uri = "https://migrationtest.vault.azure.net/"
    }
  }
}
mock_provider "azuread" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings = {
    prefixes       = []
    random_length  = 0
    passthrough    = true
    use_slug       = false
    environment    = "test"
    default_region = "region1"
    regions        = { region1 = "westeurope" }
  }
  client_config = {
    landingzone_key = "local"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
  }
  location            = "westeurope"
  resource_group_name = "migrationtest"
  resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags           = false
  remote_objects      = {}
  private_endpoints   = {}
  resource_groups     = {}
  vnets               = {}
  diagnostics         = { diagnostics_definition = {} }
}

run "container_app_template_grace_period" {
  command = plan
  module {
    source = "../modules/compute/container_app"
  }
  variables {
    container_app_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.App/managedEnvironments/test"
    diagnostic_profiles          = {}
    combined_diagnostics         = {}
    settings = {
      name          = "migrationtest"
      revision_mode = "Single"
      template = {
        termination_grace_period_seconds = 45
        container = {
          app = {
            name   = "app"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 0.25
            memory = "0.5Gi"
          }
        }
      }
    }
  }
  assert {
    condition     = azurerm_container_app.ca.template[0].termination_grace_period_seconds == 45
    error_message = "The supported template-level grace period must be preserved."
  }
}
run "container_app_legacy_probe_grace_period_rejected" {
  command = plan
  module {
    source = "../modules/compute/container_app"
  }
  variables {
    container_app_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.App/managedEnvironments/test"
    diagnostic_profiles          = {}
    combined_diagnostics         = {}
    settings = {
      name          = "migrationtest"
      revision_mode = "Single"
      template = {
        container = {
          app = {
            name   = "app"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 0.25
            memory = "0.5Gi"
            liveness_probe = {
              port                             = 8080
              transport                        = "TCP"
              termination_grace_period_seconds = 45
            }
          }
        }
      }
    }
  }
  expect_failures = [azurerm_container_app.ca]
}
