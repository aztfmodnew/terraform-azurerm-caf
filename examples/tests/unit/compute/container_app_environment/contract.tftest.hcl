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
    passthrough   = true
    use_slug      = false
  }
  client_config        = { landingzone_key = "local" }
  location             = "westeurope"
  resource_group_name  = "migrationtest"
  resource_group       = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags            = false
  diagnostics          = {}
  diagnostic_profiles  = {}
  combined_diagnostics = {}
  subnet_id            = null
}

run "legacy_workspace_logging_destination" {
  command = plan
  module {
    source = "../modules/compute/container_app_environment"
  }
  variables {
    settings = {
      name                       = "migrationtest"
      log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.OperationalInsights/workspaces/test"
    }
  }
  assert {
    condition     = azurerm_container_app_environment.cae.logs_destination == "log-analytics" && azurerm_container_app_environment.cae.log_analytics_workspace_id == var.settings.log_analytics_workspace_id
    error_message = "Legacy workspace logging requires an explicit log-analytics destination."
  }
}
run "azure_monitor_omits_workspace" {
  command = plan
  module {
    source = "../modules/compute/container_app_environment"
  }
  variables {
    settings = {
      name             = "migrationtest"
      logs_destination = "azure-monitor"
    }
  }
  assert {
    condition     = azurerm_container_app_environment.cae.logs_destination == "azure-monitor" && azurerm_container_app_environment.cae.log_analytics_workspace_id == null
    error_message = "Azure Monitor logging must not require or pass a workspace ID."
  }
}
run "streaming_only_omits_workspace" {
  command = plan
  module {
    source = "../modules/compute/container_app_environment"
  }
  variables {
    settings = {
      name             = "migrationtest"
      logs_destination = null
    }
  }
  assert {
    condition     = azurerm_container_app_environment.cae.logs_destination == null && azurerm_container_app_environment.cae.log_analytics_workspace_id == null
    error_message = "An explicit null log destination must select streaming-only logging."
  }
}
