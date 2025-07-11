# By default sp1 will inherit from the resource group location
service_plans = {
  asp_extend = {
    resource_group_key = "webapp_extend"
    name               = "asp-extend"

    os_type  = "Linux"
    sku_name = "P1v2"
  }
}
