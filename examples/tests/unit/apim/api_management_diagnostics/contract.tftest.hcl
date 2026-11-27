mock_provider "azurerm" {}

run "apim_standard_diagnostics_support_all_shared_destination_types" {
  command = plan

  module {
    source = "../modules/diagnostics"
  }

  variables {
    resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.ApiManagement/service/gateway"
    resource_location = "westeurope"
    diagnostics = {
      diagnostics_definition = {
        apim = {
          name = "gateway-telemetry"
          categories = {
            log    = [["GatewayLogs", true, false, 0]]
            metric = [["AllMetrics", true, false, 0]]
          }
        }
      }
      diagnostics_destinations = {
        log_analytics = {
          workspace = {
            log_analytics_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.OperationalInsights/workspaces/gateway"
          }
        }
        event_hub_namespaces = {
          telemetry = {
            event_hub_namespace_key = "telemetry"
          }
        }
        storage = {
          archive = {
            westeurope = {
              storage_account_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.Storage/storageAccounts/gatewayarchive"
            }
          }
        }
      }
      event_hub_namespaces = {
        telemetry = {
          id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.EventHub/namespaces/gateway"
          name = "gateway"
        }
      }
      log_analytics    = {}
      storage_accounts = {}
    }
    profiles = {
      log_analytics = {
        name             = "gateway-logs"
        definition_key   = "apim"
        destination_type = ["log_analytics"]
        destination_key  = "workspace"
      }
      event_hub = {
        name             = "gateway-events"
        definition_key   = "apim"
        destination_type = ["event_hub"]
        destination_key  = "telemetry"
        eventhub_name    = "gateway-events"
      }
      storage = {
        name             = "gateway-archive"
        definition_key   = "apim"
        destination_type = ["storage"]
        destination_key  = "archive"
      }
    }
  }

  assert {
    condition = (
      azurerm_monitor_diagnostic_setting.diagnostics["log_analytics"].log_analytics_workspace_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.OperationalInsights/workspaces/gateway" &&
      azurerm_monitor_diagnostic_setting.diagnostics["event_hub"].eventhub_name == "gateway-events" &&
      azurerm_monitor_diagnostic_setting.diagnostics["storage"].storage_account_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.Storage/storageAccounts/gatewayarchive"
    )
    error_message = "APIM standard diagnostics must retain Log Analytics, Event Hub, and Storage destination support."
  }
}
