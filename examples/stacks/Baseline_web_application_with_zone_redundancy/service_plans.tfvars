service_plans = {
  sp1 = {
    resource_group_key     = "rg1"
    name                   = "asp-simple"
    os_type                = "Windows"
    sku_name               = "P1v2"
    zone_balancing_enabled = true
    tags = {
      project = "Test"
    }
  }
}