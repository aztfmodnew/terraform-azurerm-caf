linux_function_apps = {
  lfa1 = {
    name                = "test-azure-functions"
    resource_group_key  = "rg1"
    region              = "region1"
    service_plan_key    = "asp1"
    storage_account_key = "sa1"

    functions_extension_version = "~4"

    site_config = {
      application_stack = {
        python_version = "3.9"
      }
    }

    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
    }
  }
}
