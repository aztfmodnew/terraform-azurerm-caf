global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "entra-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "entra-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_identity_provider_aad = {
  entra = {
    client_id = "00000000-0000-0000-0000-000000000001"
    # Replace placeholders through a secure, untracked variable file before deployment.
    client_secret   = "REPLACE-WITH-SECURE-INPUT"
    allowed_tenants = ["00000000-0000-0000-0000-000000000002"]
    api_management  = { key = "gateway" }
    resource_group  = { key = "gateway" }
  }
}
