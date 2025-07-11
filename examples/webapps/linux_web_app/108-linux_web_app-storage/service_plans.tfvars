# By default sp1 will inherit from the resource group location
service_plans = {
  asp_storage = {
    resource_group_key = "webapp_storage"
    name               = "asp-storage"

    os_type  = "Linux"
    sku_name = "P1v2"
  }
}
