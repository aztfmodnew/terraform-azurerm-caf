mock_provider "azurerm" {}

variables {
  cognitive_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/foundry/providers/Microsoft.CognitiveServices/accounts/foundry"
}

run "complete_deployment_contract" {
  command = plan

  module {
    source = "../modules/cognitive_services/cognitive_deployment"
  }

  variables {
    settings = {
      name                       = "chat"
      dynamic_throttling_enabled = true
      spillover_deployment_name  = "chat-standard"
      version_upgrade_option     = "OnceNewDefaultVersionAvailable"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-08-06"
      }
      sku = {
        name     = "GlobalProvisionedManaged"
        tier     = "Standard"
        capacity = 2
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
      azurerm_cognitive_deployment.service.dynamic_throttling_enabled &&
      azurerm_cognitive_deployment.service.spillover_deployment_name == "chat-standard" &&
      azurerm_cognitive_deployment.service.sku[0].capacity == 2 &&
      azurerm_cognitive_deployment.service.timeouts.create == "45m" &&
      azurerm_cognitive_deployment.service.timeouts.read == "10m" &&
      azurerm_cognitive_deployment.service.timeouts.update == "35m" &&
      azurerm_cognitive_deployment.service.timeouts.delete == "25m"
    )
    error_message = "The deployment must retain the AzureRM 5.14 throughput and timeout contract."
  }
}
