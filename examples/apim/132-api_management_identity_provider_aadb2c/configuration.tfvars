global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "b2c-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "b2c-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_identity_provider_aadb2c = {
  customers = {
    client_id = "00000000-0000-0000-0000-000000000001"
    # Use an existing B2C tenant/application and user flows; inject a real secret securely.
    client_secret  = "REPLACE-WITH-SECURE-INPUT"
    allowed_tenant = "example.onmicrosoft.com"
    signin_tenant  = "example.onmicrosoft.com"
    authority      = "example.b2clogin.com"
    signin_policy  = "B2C_1_Login"
    signup_policy  = "B2C_1_Signup"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
