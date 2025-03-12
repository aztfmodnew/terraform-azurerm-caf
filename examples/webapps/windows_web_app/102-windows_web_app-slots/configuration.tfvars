global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  webapp_region1 = {
    name   = "webapp-rg"
    region = "region1"
  }
}

# By default sp1 will inherit from the resource group location
service_plans = {
  sp1 = {
    resource_group_key = "webapp_region1"
    name               = "sp1"
    os_type            = "Windows"
    sku_name           = "P1v2"
  }
}

windows_web_apps = {
  webapp1 = {
    resource_group_key = "webapp_region1"
    name               = "webapp"
    service_plan_key   = "sp1"


    enabled = true

    site_config = {
      default_documents        = ["main.aspx"]
      always_on                = true
      dotnet_framework_version = "v4.0"
    }


    slots = {
      smoke_test = {
        name = "smoke-test"
      }
      ab_test = {
        name = "AB-testing"
      }
    }

    tags = {
      example = "simple_webapp"
    }
  }
}
