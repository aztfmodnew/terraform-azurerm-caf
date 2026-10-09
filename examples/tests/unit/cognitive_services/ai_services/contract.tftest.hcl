mock_provider "azurerm" {}
mock_provider "azurecaf" {}

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
  client_config  = { landingzone_key = "local" }
  location       = "westeurope"
  resource_group = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags      = false
  remote_objects = {}
}

run "project_management_defaults_to_system_identity" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    settings = { name = "migrationtest", sku_name = "S0" }
  }
  assert {
    condition     = azurerm_cognitive_account.ai_services.kind == "AIServices" && azurerm_cognitive_account.ai_services.project_management_enabled && azurerm_cognitive_account.ai_services.identity[0].type == "SystemAssigned"
    error_message = "The legacy AI Services mode requires a default system-assigned identity."
  }
}
run "disabled_projects_do_not_inject_identity" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    settings = {
      name                         = "migrationtest"
      sku_name                     = "S0"
      project_management_enabled   = false
      public_network_access        = "Disabled"
      local_authentication_enabled = false
    }
  }
  assert {
    condition     = length(azurerm_cognitive_account.ai_services.identity) == 0 && !azurerm_cognitive_account.ai_services.public_network_access_enabled && !azurerm_cognitive_account.ai_services.local_auth_enabled
    error_message = "Disabled project management must not inject an identity, and legacy network/auth flags must be preserved."
  }
}
run "explicit_identity_and_current_flags_are_preserved" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    remote_objects = {
      managed_identities = {
        local = {
          test = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test" }
        }
      }
    }
    settings = {
      name                          = "migrationtest"
      sku_name                      = "S0"
      public_network_access         = "Disabled"
      public_network_access_enabled = true
      local_authentication_enabled  = false
      local_auth_enabled            = true
      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["test"]
      }
    }
  }
  assert {
    condition     = azurerm_cognitive_account.ai_services.identity[0].type == "UserAssigned" && azurerm_cognitive_account.ai_services.identity[0].identity_ids == toset([var.remote_objects.managed_identities.local.test.id]) && azurerm_cognitive_account.ai_services.public_network_access_enabled && azurerm_cognitive_account.ai_services.local_auth_enabled
    error_message = "Explicit identities and current network/auth settings must take precedence."
  }
}
