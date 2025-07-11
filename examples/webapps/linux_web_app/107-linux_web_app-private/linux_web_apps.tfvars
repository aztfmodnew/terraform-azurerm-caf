linux_web_apps = {
  webapp1 = {
    resource_group_key = "webapp_simple"
    name               = "webapp-simple"
    service_plan_key   = "sp1"

    vnet_integration = {
      vnet_key   = "spoke"
      subnet_key = "app"
    }

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
    }

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }

    private_endpoints = {
      webapp_private = {
        name               = "webapp-private"
        vnet_key           = "spoke"
        subnet_key         = "app"
        resource_group_key = "webapp_simple"

        private_service_connection = {
          name                 = "webapp-private-connection"
          is_manual_connection = false
          subresource_names    = ["sites"]
        }
      }
    }
  }
}
