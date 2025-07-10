linux_web_apps = {
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
      default_documents        = ["index.html"]
      always_on                = true
      app_command_line         = null
      ftps_state               = "AllAllowed" //AllAllowed, FtpsOnly and Disabled
      http2_enabled            = false

      application_stack = {
        python_version = "3.8"
      }

      cors = {
        allowed_origins = ["*"]
      }

      ip_restriction = {
        ip_restriction_1 = {
          name     = "test"
          priority = 100
          action   = "Allow"
          ip_address = "10.0.0.0/8"
        }
      }

      scm_ip_restriction = {
        scm_ip_restriction_1 = {
          name     = "test"
          priority = 100
          action   = "Allow"
          ip_address = "10.0.0.0/8"
        }
      }

      storage_account = {
        storage_account_1 = {
          name         = "test"
          type         = "AzureFiles"
          account_name = "test"
          share_name   = "test"
          access_key   = "test"
          mount_path   = "/test"
        }
      }
    }

    connection_string = {
      database_1 = {
        name  = "Database"
        type  = "SQLServer"
        value = "Server=tcp:azuresql.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;"
      }
    }

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
    }
  }
}
