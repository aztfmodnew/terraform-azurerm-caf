global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "twitter-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "twitter-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_identity_provider_twitter = {
  twitter = {
    # Configure the external application and inject both credentials securely.
    api_key        = "REPLACE-WITH-SECURE-INPUT"
    api_secret_key = "REPLACE-WITH-SECURE-INPUT"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
