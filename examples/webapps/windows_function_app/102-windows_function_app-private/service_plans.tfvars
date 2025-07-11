# Windows service plan for Function App
service_plans = {
  asp1 = {
    resource_group_key = "funapp"
    name               = "win-funapp-plan"
    os_type            = "Windows"
    sku_name           = "P1v3"  # Premium for VNet integration
    
    tags = {
      project = "Windows Functions"
      tier    = "Premium"
    }
  }
}