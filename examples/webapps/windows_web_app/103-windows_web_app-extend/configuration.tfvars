global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  webapp_extend = {
    name   = "webapp-extend"
    region = "region1"
  }
}

# By default sp1 will inherit from the resource group location
service_plans = {
  asp_extend = {
    resource_group_key = "webapp_extend"
    name               = "asp-extend"

    os_type  = "Windows"
    sku_name = "P1v2"
  }
}

windows_web_apps = {
  webapp1 = {
    resource_group_key = "webapp_extend"
    name               = "webapp-extend"
    service_plan_key   = "asp_extend"

    identity = {
      type = "SystemAssigned"
    }


    enabled                 = true
    client_affinity_enabled = false
    client_cert_enabled     = false
    https_only              = false

    site_config = {
      number_of_workers        = 2
      default_documents        = ["main.aspx"]
      always_on                = true
      dotnet_framework_version = "v4.0"
      app_command_line         = null         ///sbin/myserver -b 0.0.0.0
      ftps_state               = "AllAllowed" //AllAllowed, FtpsOnly and Disabled
      http2_enabled            = false

      ip_restriction = [
        {
          name       = "deny-all-traffic"
          action     = "Deny"
          ip_address = "0.0.0.0/0"
          priority   = 65000
        }
      ]

      scm_ip_restriction = [
        {
          name       = "allow-all-traffic"
          action     = "Allow"
          ip_address = "0.0.0.0/0"
          priority   = 65000
        }
      ]
    }

    app_settings = {
      "Example" = "Extend",
      "LZ"      = "CAF"
    }

    tags = {
      Department = "IT"
    }

  }
}
