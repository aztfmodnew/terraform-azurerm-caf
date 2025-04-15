global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  inherit_tags = true
  tags = {
    environment = "production"
  }
}

resource_groups = {
  rg1 = {
    name   = "example-rg"
    region = "region1"
  }
}

service_plans = {
  sp1 = {
    resource_group_key = "rg1"
    name               = "asp-simple"
    os_type            = "Windows"
    sku_name           = "P1v2"
    tags = {
      project = "Test"
    }
  }
}

windows_web_apps = {
  webapp1 = {
    name               = "example-webapp"
    resource_group_key = "rg1"
    service_plan_key   = "sp1"

    enabled = true

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "14.17.0"
    }
    tags = {
      project = "example-project"
    }
  }
}