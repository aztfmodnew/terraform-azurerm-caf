global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "named-value-workspace", region = "region1" }
}
api_management = {
  gateway = {
    name            = "named-value-workspace"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Premium_1"
  }
}
api_management_workspace = {
  team = {
    name           = "payments"
    display_name   = "Payments"
    api_management = { key = "gateway" }
  }
}
api_management_workspace_named_value = {
  backend = {
    name                     = "backend-endpoint"
    display_name             = "backend-endpoint"
    value                    = "https://backend.example.com"
    tags                     = ["payments", "backend"]
    api_management_workspace = { key = "team" }
  }
}
