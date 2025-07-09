linux_web_apps = {
  simple_app = {
    name               = "simple-linux-web-app"
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

    slots = {
      staging = {
        name = "staging"
        
        app_settings = {
          "WEBSITE_NODE_DEFAULT_VERSION" = "~22"
          "WEBSITE_RUN_FROM_PACKAGE"     = "1"
          "ENVIRONMENT"                  = "staging"
          "NODE_ENV"                     = "staging"
        }
        
        site_config = {
          always_on                         = true
          health_check_path                 = "/health"
          health_check_eviction_time_in_min = 5
          minimum_tls_version               = "1.2"
          ftps_state                        = "FtpsOnly"
          http2_enabled                     = true
          
          application_stack = {
            node_version = "22-lts"
          }
        }
      }
      
      testing = {
        name = "testing"
        
        app_settings = {
          "WEBSITE_NODE_DEFAULT_VERSION" = "~22"
          "WEBSITE_RUN_FROM_PACKAGE"     = "1"
          "ENVIRONMENT"                  = "testing"
          "NODE_ENV"                     = "testing"
          "FEATURE_FLAGS"                = "experimental"
        }
        
        site_config = {
          always_on                         = true
          health_check_path                 = "/health"
          health_check_eviction_time_in_min = 5
          minimum_tls_version               = "1.2"
          ftps_state                        = "FtpsOnly"
          http2_enabled                     = true
          
          application_stack = {
            node_version = "22-lts"
          }
        }
      }
    }

    tags = {
      environment = "development"
      purpose     = "slots-example"
    }
  }
}
