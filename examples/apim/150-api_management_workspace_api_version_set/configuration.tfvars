global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "versioned-workspace-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "versioned-workspace-gateway"
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
api_management_workspace_api_version_set = {
  payments = {
    name                     = "payments-versions"
    display_name             = "Payments versions"
    versioning_scheme        = "Segment"
    api_management_workspace = { key = "team" }
  }
}
