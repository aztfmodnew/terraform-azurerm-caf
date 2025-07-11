linux_web_apps = {
  # By default webapp1 will inherit from the resource group location
  # and the app service plan location
  webapp1 = {
    resource_group_key = "webapp_simple"
    name               = "webapp-simple"
    service_plan_key   = "sp1"
    enabled            = true

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "18.0"
    }

    site_config = {
      application_stack = {
        node_version = "18-lts"
      }
    }

    tags = {
      project = "Mobile app"
    }
  }
}
