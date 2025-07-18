service_plans = {
  asp1 = {
    name               = "azure-functions-test-service-plan"
    resource_group_key = "my_rg"
    region             = "australiaeast"
    os_type            = "Linux"
    sku_name           = "S1" # For vnet integration
  }
}

function_apps = {
  faaps1 = {
    name                = "test-azure-functions"
    resource_group_key  = "my_rg"
    region              = "australiaeast"
    service_plan_key    = "asp1"
    storage_account_key = "sa1"
    settings = {
      os_type    = "linux"
      version    = "~3"
      vnet_key   = "vnet_existing"
      subnet_key = "apps" # Make sure the subnet has Microsoft.Web/serverFarms delegation.
      enabled    = true
    }
  }
}