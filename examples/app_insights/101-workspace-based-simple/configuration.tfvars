global_settings = {
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  rg1 = {
    name = "example-appinsight-rg"
  }
}

log_analytics = {
  law1 = {
    name                       = "appinsightexamplelaw"
    resource_group_key         = "rg1"
    internet_ingestion_enabled = false
    internet_query_enabled     = false
  }
  current = {
    name                           = "currentlaw"
    resource_group_key             = "rg1"
    internet_ingestion_access_type = "Enabled"
    internet_query_access_type     = "Enabled"
    internet_ingestion_enabled     = false
    internet_query_enabled         = false
  }
}


azurerm_application_insights = {
  webapp = {
    name               = "example-appinsights-web"
    resource_group_key = "rg1"
    application_type   = "web"
    log_analytics_workspace = {
      # lz_key = ""
      key = "law1"
    }
  }
  legacy = {
    name                                  = "legacy-flags"
    resource_group_key                    = "rg1"
    application_type                      = "web"
    daily_data_cap_notifications_disabled = true
    disable_ip_masking                    = true
    log_analytics_workspace               = { key = "law1" }
  }
  current = {
    name                                  = "current-flags"
    resource_group_key                    = "rg1"
    application_type                      = "web"
    daily_data_cap_notifications_enabled  = true
    daily_data_cap_notifications_disabled = true
    ip_masking_enabled                    = true
    disable_ip_masking                    = true
    log_analytics_workspace               = { key = "current" }
  }
}