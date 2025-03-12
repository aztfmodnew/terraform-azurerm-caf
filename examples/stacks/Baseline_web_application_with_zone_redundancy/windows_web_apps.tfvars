windows_web_apps = {
  webapp1 = {
    name                          = "example-webapp1417"
    resource_group_key            = "rg1"
    service_plan_key              = "sp1"
    enabled                       = true
    https_only                    = false
    public_network_access_enabled = false
    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "14.17.0"
    }

    virtual_network_subnet = {
      # lz_key = ""
      vnet_key   = "vnet1"
      subnet_key = "app_service_integration"
      #subnet_id = "/subscriptions/000000000/resourceGroups/rg1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/app_service_integration"

    }
    # Optional
    private_endpoints = {
      # Require enforce_private_link_endpoint_network_policies set to true on the subnet
      private-link-webapp1 = {
        name       = "example-webapp1"
        vnet_key   = "vnet1"
        subnet_key = "private_endpoints"
        #subnet_id          = "/subscriptions/97958dac-f75b-4ee3-9a07-9f436fa73bd4/resourceGroups/ppga-rg-sql-rg1/providers/Microsoft.Network/virtualNetworks/ppga-vnet-testvnet1/subnets/ppga-snet-web-subnet"
        resource_group_key = "rg1"

        private_service_connection = {
          name                 = "example-webapp1"
          is_manual_connection = false
          #https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
          subresource_names = ["sites"]
        }

        private_dns = {
          zone_group_name = "privatelink_azurewebsites_windows_net"
          # lz_key          = ""   # If the DNS keys are deployed in a remote landingzone
          keys = ["azurewebsites_dns"]
        }
      }
    }
    tags = {
      project = "example-project"
    }
  }
}


monitor_autoscale_settings = {
  mas1 = {
    name               = "mas1"
    enabled            = true
    resource_group_key = "rg1"

    target_resource = {
      # lz_key = ""
      # vmss_key = ""
      # app_service_plan_key = ""
      service_plan_key = "sp1"

    }

    profiles = {
      profile1 = {
        name = "profile1"

        capacity = {
          default = 1
          minimum = 1
          maximum = 3
        }

        rules = {
          rule1 = {
            metric_trigger = {

              # metric_name = "Percentage CPU" # vmss uses this
              # You can also choose your resource id manually, in case it is required
              # metric_resource_id = "/subscriptions/manual-id"
              metric_name      = "CpuPercentage"
              metric_namespace = "microsoft.web/serverfarms"
              time_grain       = "PT1M"
              statistic        = "Average"
              time_window      = "PT10M"
              time_aggregation = "Average"
              operator         = "GreaterThan"
              threshold        = 70
              # You can optionally fill the following fields

              # divide_by_instance_count = true

              # dimensions = {
              #   dimension1 = {
              #     name     = "App1"
              #     operator = "Equals"
              #     values   = []
              #   }

              # }

            }
            scale_action = {
              direction = "Increase"
              type      = "ChangeCount"
              value     = "1"
              cooldown  = "PT5M"
            }

          }
        }

      }
    }
  }
}