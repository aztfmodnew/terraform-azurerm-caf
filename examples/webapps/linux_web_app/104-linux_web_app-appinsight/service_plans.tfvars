# By default sp1 will inherit from the resource group location
service_plans = {
  sp1 = {
    resource_group_key = "webapp_simple"
    name               = "asp-simple"

    os_type  = "Linux"
    sku_name = "P1v2"
  }
}
