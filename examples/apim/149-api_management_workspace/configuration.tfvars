global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "workspace-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "workspace-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    # AzureRM 5.14.0 documents Classic Premium support for workspaces.
    sku_name = "Premium_1"
  }
}
api_management_workspace = {
  team = {
    name           = "payments"
    display_name   = "Payments"
    description    = "Payment APIs managed by the payments team"
    api_management = { key = "gateway" }
  }
}
