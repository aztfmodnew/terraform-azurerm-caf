service_plans = {
  sp1 = {
    resource_group_key = "rg1"
    name               = "asp-simple"

    maximum_elastic_worker_count = 5
    os_type                      = "Linux"
    sku_name                     = "S1"
  }
}
