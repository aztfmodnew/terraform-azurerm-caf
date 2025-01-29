linux_function_apps = {
  linux_function_app1 = {
    name                = "funapp"
    resource_group_key  = "test_re1"
    service_plan_key    = "sp1"
    storage_account_key = "sa1"

    site_config = {
      ftps_state = "Disabled"
      application_stack = {
        python_version = 3.12
      }

    }
  }
}
