global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "microsoft-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "microsoft-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_identity_provider_microsoft = {
  microsoft = {
    client_id = "00000000-0000-0000-0000-000000000001"
    # Configure the external application and inject its secret securely.
    client_secret  = "REPLACE-WITH-SECURE-INPUT"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
