linux_web_apps = {
  webapp1 = {
    resource_group_key = "webapprg"
    name               = "webapp-diagnostics"
    service_plan_key   = "sp1"

    identity = {
      type = "SystemAssigned"
    }

    enabled                 = true
    client_affinity_enabled = false
    client_cert_enabled     = false
    https_only              = false

    site_config = {
      default_documents        = ["index.html"]
      always_on                = true
      app_command_line         = null
      ftps_state               = "AllAllowed" //AllAllowed, FtpsOnly and Disabled
      http2_enabled            = false

      application_stack = {
        python_version = "3.8"
      }
    }

    app_settings = {
      "Example" = "Extend",
      "LZ"      = "CAF"
    }

    tags = {
      Department = "IT"
    }

    diagnostic_profiles = {
      central_logs_example = {
        definition_key   = "azurerm_linux_web_app"
        destination_type = "event_hub"
        destination_key  = "central_logs_example"
      }
    }
  }
}
