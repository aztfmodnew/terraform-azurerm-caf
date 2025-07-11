service_plans = {
  linux_plan = {
    name               = "linux-service-plan"
    resource_group_key = "webapp_rg"
    os_type            = "Linux"
    sku_name           = "B1"

    tags = {
      environment = "development"
      purpose     = "example"
    }
  }
}
