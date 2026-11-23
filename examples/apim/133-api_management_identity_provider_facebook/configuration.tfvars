global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "facebook-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "facebook-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_identity_provider_facebook = {
  facebook = {
    app_id = "123456789012345"
    # Configure the external app and inject its secret securely before deployment.
    app_secret     = "REPLACE-WITH-SECURE-INPUT"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
