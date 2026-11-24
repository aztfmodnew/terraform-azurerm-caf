mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "observability-law" }
  }
}

run "workspace_complete_azure_5_14_contract" {
  command = plan

  module {
    source = "../modules/log_analytics"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    location = "westeurope"
    resource_group = {
      name     = "observability"
      location = "westeurope"
    }
    resource_group_name = "observability"
    base_tags           = false
    log_analytics = {
      name                                    = "observability-law"
      allow_resource_only_permissions         = false
      cmk_for_query_forced                    = true
      daily_quota_gb                          = 10
      data_collection_rule_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.Insights/dataCollectionRules/workspace"
      immediate_data_purge_on_30_days_enabled = true
      local_authentication_enabled            = false
      reservation_capacity_in_gb_per_day      = 100
      sku                                     = "CapacityReservation"
      retention_in_days                       = 90
      identity = {
        type = "UserAssigned"
        identity_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.ManagedIdentity/userAssignedIdentities/workspace"
        ]
      }
      timeouts = {
        create = "45m"
        read   = "6m"
        update = "45m"
        delete = "45m"
      }
      solutions_maps = {
        ContainerInsights = {
          publisher      = "Microsoft"
          product        = "OMSGallery/ContainerInsights"
          promotion_code = "preview"
          timeouts = {
            create = "40m"
            read   = "6m"
            update = "40m"
            delete = "40m"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azurerm_log_analytics_workspace.law.allow_resource_only_permissions == false &&
      azurerm_log_analytics_workspace.law.cmk_for_query_forced == true &&
      azurerm_log_analytics_workspace.law.data_collection_rule_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.Insights/dataCollectionRules/workspace" &&
      azurerm_log_analytics_workspace.law.immediate_data_purge_on_30_days_enabled == true &&
      azurerm_log_analytics_workspace.law.local_authentication_enabled == false &&
      azurerm_log_analytics_workspace.law.identity[0].identity_ids == toset(["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/observability/providers/Microsoft.ManagedIdentity/userAssignedIdentities/workspace"]) &&
      azurerm_log_analytics_workspace.law.timeouts.update == "45m" &&
      azurerm_log_analytics_solution.solution["ContainerInsights"].timeouts.update == "40m"
    )
    error_message = "All AzureRM 5.14 Log Analytics workspace and solution attributes must reach the resources."
  }
}

run "legacy_network_and_reservation_aliases_remain_supported" {
  command = plan

  module {
    source = "../modules/log_analytics"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    resource_group = {
      name     = "observability"
      location = "westeurope"
    }
    base_tags = false
    log_analytics = {
      name                              = "legacy-law"
      internet_ingestion_enabled        = false
      internet_query_enabled            = false
      reservation_capcity_in_gb_per_day = 100
      sku                               = "CapacityReservation"
      allow_resource_only_permissions   = true
      local_authentication_enabled      = true
    }
  }

  assert {
    condition = (
      azurerm_log_analytics_workspace.law.internet_ingestion_access_type == "Disabled" &&
      azurerm_log_analytics_workspace.law.internet_query_access_type == "Disabled" &&
      azurerm_log_analytics_workspace.law.reservation_capacity_in_gb_per_day == 100
    )
    error_message = "Legacy internet_* and misspelled reservation_capcity_* inputs must remain supported."
  }
}
