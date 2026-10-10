mock_provider "azurerm" {}
mock_provider "azurecaf" {}

variables {
  name                = "contract-insights"
  location            = "westeurope"
  resource_group_name = "contract-rg"
  tags                = {}
  base_tags           = {}
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
  }
  diagnostic_profiles = null
}

run "passes_access_profiler_and_all_timeouts" {
  command = plan
  module {
    source = "../modules/app_insights"
  }
  variables {
    settings = {
      local_authentication_enabled        = false
      internet_ingestion_enabled          = false
      internet_query_enabled              = false
      force_customer_storage_for_profiler = true
      timeouts = {
        create = "70m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }
  assert {
    condition = (
      !azurerm_application_insights.appinsights.local_authentication_enabled &&
      !azurerm_application_insights.appinsights.internet_ingestion_enabled &&
      !azurerm_application_insights.appinsights.internet_query_enabled &&
      azurerm_application_insights.appinsights.force_customer_storage_for_profiler &&
      azurerm_application_insights.appinsights.timeouts.create == "70m" &&
      azurerm_application_insights.appinsights.timeouts.read == "6m" &&
      azurerm_application_insights.appinsights.timeouts.update == "40m" &&
      azurerm_application_insights.appinsights.timeouts.delete == "40m"
    )
    error_message = "Access, profiler and timeout settings must reach the provider."
  }
}

run "preserves_provider_defaults_and_legacy_aliases" {
  command = plan
  module {
    source = "../modules/app_insights"
  }
  variables {
    daily_data_cap_notifications_disabled = true
    disable_ip_masking                    = true
  }
  assert {
    condition = (
      azurerm_application_insights.appinsights.local_authentication_enabled &&
      azurerm_application_insights.appinsights.internet_ingestion_enabled &&
      azurerm_application_insights.appinsights.internet_query_enabled &&
      !azurerm_application_insights.appinsights.force_customer_storage_for_profiler &&
      !azurerm_application_insights.appinsights.daily_data_cap_notifications_enabled &&
      !azurerm_application_insights.appinsights.ip_masking_enabled
    )
    error_message = "Omitted new settings and legacy disabled aliases must preserve existing behavior."
  }
}

run "current_aliases_override_legacy_disabled_flags" {
  command = plan
  module {
    source = "../modules/app_insights"
  }

  variables {
    daily_data_cap_notifications_disabled = true
    daily_data_cap_notifications_enabled  = true
    disable_ip_masking                    = true
    ip_masking_enabled                    = true
  }
  assert {
    condition = (
      azurerm_application_insights.appinsights.daily_data_cap_notifications_enabled &&
      azurerm_application_insights.appinsights.ip_masking_enabled
    )
    error_message = "Current enabled flags must retain precedence over legacy disabled aliases."
  }
}
