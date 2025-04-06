windows_web_apps = {
  webapp1 = {
    name                          = "example-webapp1417"
    resource_group_key            = "rg1"
    service_plan_key              = "sp1"
    enabled                       = true
    https_only                    = false
    public_network_access_enabled = true
    zip_deploy_file               = "stacks/Baseline_web_application_with_zone_redundancy/SimpleWebApp.zip"
    application_insight_key       = "app_insights1"



    identity = {
      type = "UserAssigned"
      # lz_key = ""
      managed_identity_keys = ["webapp_mi"]
    }

    site_config = {
      always_on = true
      application_stack = {
        current_stack  = "dotnet"
        dotnet_version = "v4.0"
      }
      http2_enabled             = true
      minimum_tls_version       = "1.3"
      ftps_state                = "Disabled"
      use_32_bit_worker_process = false
      vnet_route_all            = true


    }

    # Optional
    app_settings = {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }

    connection_strings = [
      {
        name     = "AZURE_SQL_CONNECTIONSTRING"
        type     = "SQLAzure"
        mssql_server_key = "adventureworks-rg1"
        mssql_database_key = "mssql_db1"
        # lz_key = ""
      }
    ]

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
