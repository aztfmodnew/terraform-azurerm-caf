windows_function_apps = {
  wfa1 = {
    name               = "test-azure-functions"
    resource_group_key = "rg1"
    region             = "region1"
    service_plan_key   = "asp1"
    storage_account_key = "sa1"
    
    functions_extension_version = "~4"
    
    site_config = {
      application_stack = {
        dotnet_version = "v6.0"
      }
    }
    
    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    }
  }
}
