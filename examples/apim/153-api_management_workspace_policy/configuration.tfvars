global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "policy-workspace", region = "region1" }
}
api_management = {
  gateway = {
    name            = "policy-workspace"
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
api_management_workspace_policy = {
  team = {
    api_management_workspace = { key = "team" }
    xml_content              = "<policies><inbound><base /><set-header name=\"X-Team\" exists-action=\"override\"><value>payments</value></set-header></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>"
  }
}
