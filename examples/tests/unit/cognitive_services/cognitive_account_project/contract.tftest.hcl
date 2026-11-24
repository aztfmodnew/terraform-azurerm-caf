mock_provider "azurerm" {}

variables {
  global_settings = {
    default_region = "region1"
    regions        = { region1 = "westeurope" }
  }
  client_config = {
    landingzone_key = "local"
  }
  cognitive_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/foundry/providers/Microsoft.CognitiveServices/accounts/foundry"
  remote_objects = {
    managed_identities = {
      local = {
        project = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/foundry/providers/Microsoft.ManagedIdentity/userAssignedIdentities/project"
        }
      }
    }
  }
}

run "complete_project_contract" {
  command = apply

  module {
    source = "../modules/cognitive_services/cognitive_account_project"
  }

  variables {
    base_tags = true
    settings = {
      name         = "gateway-project"
      description  = "AI Gateway Foundry project"
      display_name = "AI Gateway Foundry"
      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["project"]
      }
      tags = {
        environment = "test"
      }
      timeouts = {
        create = "45m"
        read   = "10m"
        update = "35m"
        delete = "25m"
      }
    }
  }

  assert {
    condition = (
      azurerm_cognitive_account_project.project.name == "gateway-project" &&
      azurerm_cognitive_account_project.project.location == "westeurope" &&
      azurerm_cognitive_account_project.project.identity[0].type == "UserAssigned" &&
      azurerm_cognitive_account_project.project.identity[0].identity_ids == toset([var.remote_objects.managed_identities.local.project.id]) &&
      azurerm_cognitive_account_project.project.description == "AI Gateway Foundry project" &&
      azurerm_cognitive_account_project.project.display_name == "AI Gateway Foundry" &&
      azurerm_cognitive_account_project.project.timeouts.create == "45m" &&
      azurerm_cognitive_account_project.project.timeouts.read == "10m" &&
      azurerm_cognitive_account_project.project.timeouts.update == "35m" &&
      azurerm_cognitive_account_project.project.timeouts.delete == "25m"
    )
    error_message = "The project must preserve the complete identity, metadata, output, and timeout contract."
  }

  assert {
    condition = (
      output.default == azurerm_cognitive_account_project.project.default &&
      output.endpoints == azurerm_cognitive_account_project.project.endpoints &&
      output.principal_id == azurerm_cognitive_account_project.project.identity[0].principal_id &&
      output.tenant_id == azurerm_cognitive_account_project.project.identity[0].tenant_id &&
      output.rbac_id == azurerm_cognitive_account_project.project.identity[0].principal_id
    )
    error_message = "Project computed endpoint, default, and identity values must be exposed by the module outputs."
  }
}

run "defaults_to_system_identity" {
  command = plan

  module {
    source = "../modules/cognitive_services/cognitive_account_project"
  }

  variables {
    settings = {
      name = "system-project"
    }
  }

  assert {
    condition     = azurerm_cognitive_account_project.project.identity[0].type == "SystemAssigned"
    error_message = "Project identity must default to SystemAssigned."
  }
}
