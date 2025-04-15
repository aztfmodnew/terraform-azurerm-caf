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
  spoke = {
    name   = "spoke"
    region = "region1"
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

  }
}

vnets = {
  spoke = {
    resource_group_key = "spoke"
    region             = "region1"
    vnet = {
      name          = "spoke"
      address_space = ["10.1.0.0/24"]
    }
    specialsubnets = {}
    subnets = {
      app = {
        name = "app"
        cidr = ["10.1.0.0/28"]
        delegation = {
          name               = "serverFarms"
          service_delegation = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
    }

  }

}

network_security_group_definition = {
  # This entry is applied to all subnets with no NSG defined
  empty_nsg = {
  }
}

