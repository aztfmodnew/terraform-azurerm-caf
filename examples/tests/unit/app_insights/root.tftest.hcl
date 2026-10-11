mock_provider "azurerm" {
  source = "./tests/mock_data"
}
mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}
mock_provider "azuread" {
  source = "./tests/mock_data"
}
mock_provider "azapi" {
  source = "./tests/mock_data"
}
mock_provider "external" {
  source = "./tests/mock_data"
}

run "root_preserves_direct_workspace_id_precedence" {
  command = plan
  module {
    source = "../"
  }
  variables {
    global_settings = {
      default_region = "region1"
      regions        = { region1 = "westeurope" }
      random_length  = 0
    }
    resource_groups = {
      contract = { name = "contract-insights" }
    }
    webapp = {
      azurerm_application_insights = {
        contract = {
          name               = "contract-insights"
          resource_group_key = "contract"
          workspace_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/contract-rg/providers/Microsoft.OperationalInsights/workspaces/direct"
          log_analytics_workspace = {
            key = "missing"
          }
        }
      }
    }
  }
  assert {
    condition     = output.application_insights["contract"].workspace_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/contract-rg/providers/Microsoft.OperationalInsights/workspaces/direct"
    error_message = "Root wiring must preserve a direct workspace ID before attempting key-based fallbacks."
  }
}
