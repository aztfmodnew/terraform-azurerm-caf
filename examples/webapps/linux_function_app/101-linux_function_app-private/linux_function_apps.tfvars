linux_function_apps = {
  f1 = {
    name               = "funapp-private"
    resource_group_key = "funapp"
    region             = "region1"

    service_plan_key    = "asp1"
    storage_account_key = "sa1"

    settings = {
      vnet_key   = "spoke"
      subnet_key = "app"
      #subnet_id = "/subscriptions/97958dac-xxxx-xxxx-xxxx-9f436fa73bd4/resourceGroups/jana-rg-spoke/providers/Microsoft.Network/virtualNetworks/jana-vnet-spoke/subnets/jana-snet-app"
      enabled = true
    }

    functions_extension_version = "~4"

    site_config = {
      application_stack = {
        python_version = "3.9"
      }
    }

    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
    }

    tags = {
      application = "payment"
      env         = "uat"
    }
  }
}
