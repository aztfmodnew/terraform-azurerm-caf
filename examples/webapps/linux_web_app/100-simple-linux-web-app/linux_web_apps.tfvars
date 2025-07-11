linux_web_apps = {
  example_app = {
    name               = "example-linux-web-app"
    resource_group_key = "webapp_rg"
    service_plan_key   = "linux_plan"

    site_config = {
      always_on                         = true
      ftps_state                        = "Disabled"
      http2_enabled                     = true
      health_check_path                 = "/health"
      health_check_eviction_time_in_min = 5

      application_stack = {
        node_version = "22-lts"
      }
    }

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "~22"
      "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    }

    tags = {
      environment = "development"
      purpose     = "example"
    }
  }
}
