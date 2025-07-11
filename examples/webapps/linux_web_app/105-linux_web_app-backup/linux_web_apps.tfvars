linux_web_apps = {
  webapp1 = {
    resource_group_key = "webapp_backup"
    name               = "webapp-backup"
    service_plan_key   = "sp1"

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
    }

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }

    backup = {
      name                = "test"
      enabled             = true
      storage_account_key = "sa1"
      container_key       = "backup"

      sas_policy = {
        expire_in_days = 30
        rotation = {
          #
          # Set how often the sas token must be rotated. When passed the renewal time, running the terraform plan / apply will change to a new sas token
          # Only set one of the value
          #

          # mins = 1 # only recommended for CI and demo
          days = 7
          # months = 1
        }
      }

      schedule = {
        frequency_interval       = 7
        frequency_unit           = "Day"
        keep_at_least_one_backup = true
        retention_period_in_days = 30
        start_time               = "2021-01-01T00:00:00Z"
      }
    }

    logs = {
      detailed_error_messages_enabled = true
      failed_request_tracing_enabled  = true

      application_logs = {
        file_system_level = "Information"
        azure_blob_storage = {
          level             = "Information"
          retention_in_days = 7
        }
      }

      # lz_key = ""  # if in remote landingzone
      storage_account_key = "logs"
      container_key       = "logs"

      sas_policy = {
        expire_in_days = 30
        rotation = {
          #
          # Set how often the sas token must be rotated. When passed the renewal time, running the terraform plan / apply will change to a new sas token
          # Only set one of the value
          #

          # mins = 1 # only recommended for CI and demo
          days = 7
          # months = 1
        }
      }

      http_logs = {
        azure_blob_storage = {
          retention_in_days = 7
        }

        storage_account_key = "logs"
        container_key       = "http_logs"
        sas_policy = {
          expire_in_days = 30
          rotation = {
            #
            # Set how often the sas token must be rotated. When passed the renewal time, running the terraform plan / apply will change to a new sas token
            # Only set one of the value
            #

            # mins = 1 # only recommended for CI and demo
            days = 7
            # months = 1
          }
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
  }
}
