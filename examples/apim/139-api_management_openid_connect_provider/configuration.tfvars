global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "openid-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "openid-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_openid_connect_provider = {
  partner = {
    name         = "partner"
    display_name = "Partner OpenID"
    client_id    = "00000000-0000-0000-0000-000000000001"
    # Replace registration, discovery URI and secret with real provider inputs.
    client_secret     = "REPLACE-WITH-SECURE-INPUT"
    metadata_endpoint = "https://login.example.com/.well-known/openid-configuration"
    api_management    = { key = "gateway" }
    resource_group    = { key = "gateway" }
  }
}
