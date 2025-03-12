global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
  inherit_tags = true
  tags = {
    env = "to_be_set"
  }
}

resource_groups = {
  webapp_simple = {
    name   = "webapp-simple"
    region = "region1"
  }
}

# By default sp1 will inherit from the resource group location
service_plans = {
  sp1 = {
    resource_group_key = "webapp_simple"
    name               = "sp-simple"
    os_type            = "Windows"
    sku_name           = "P1v2"
    tags = {
      env = "uat"
    }
  }
}

windows_web_apps = {
  # By default webapp1 will inherit from the resource group location
  # and the app service plan location
  webapp1 = {
    resource_group_key = "webapp_simple"
    name               = "webapp-simple"
    service_plan_key   = "sp1"
    enabled            = true

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
    }


    tags = {
      project = "Mobile app"
    }
  }
}
