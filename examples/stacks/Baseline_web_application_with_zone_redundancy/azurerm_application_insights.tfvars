azurerm_application_insights = {
  app_insights1 = {
    name               = "appinsights-simple"
    resource_group_key = "rg1"
    application_type   = "web"
    log_analytics_workspace = {
      # lz_key = ""
      key = "law1"
    }
  }
}