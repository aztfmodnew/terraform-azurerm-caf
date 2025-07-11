linux_web_apps = {
  webapp_appgw = {
    resource_group_key = "webapp_appgw"
    name               = "webapp-appgw"
    service_plan_key   = "webapp_appgw"

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }

    vnet_integration = {
      vnet_key   = "webapp_appgw"
      subnet_key = "webapp"
    }

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
    }
  }
}
