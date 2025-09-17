# Application Insights for Bot Telemetry
azurerm_application_insights = {
  bot_appinsights = {
    name               = "secure-bot-appinsights"
    resource_group_key = "bot_rg"
    application_type   = "web"

    # Retention and sampling
    retention_in_days   = 90
    sampling_percentage = 100

    tags = {
      monitoring = "application-insights"
      service    = "bot-telemetry"
      purpose    = "performance-monitoring"
    }
  }
}
