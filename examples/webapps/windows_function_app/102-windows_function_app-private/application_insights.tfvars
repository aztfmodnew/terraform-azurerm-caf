# Application Insights
azurerm_application_insights = {
  appinsights1 = {
    name               = "appinsights-winfunapp"
    resource_group_key = "funapp"
    application_type   = "web"
    retention_in_days  = 90

    # Disable public network access
    internet_ingestion_enabled = false
    internet_query_enabled     = false

    tags = {
      project = "Windows Functions"
      purpose = "Monitoring"
    }
  }
}