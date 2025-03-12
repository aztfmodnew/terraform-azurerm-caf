global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  webapp_simple = {
    name   = "webapp-simple"
    region = "region1"
  }
}

azurerm_application_insights = {
  app_insights1 = {
    name               = "appinsights-simple"
    resource_group_key = "webapp_simple"
    application_type   = "web"
  }
}

# By default sp1 will inherit from the resource group location
app_service_plans = {
  sp1 = {
    resource_group_key = "webapp_simple"
    name               = "asp-simple"

    os_type  = "Windows"
    sku_name = "P1v2"
  }
}

windows_web_apps = {
  webapp1 = {
    resource_group_key      = "webapp_simple"
    name                    = "webapp-simple"
    service_plan_key        = "sp1"
    application_insight_key = "app_insights1"


    enabled = true

  }
}
