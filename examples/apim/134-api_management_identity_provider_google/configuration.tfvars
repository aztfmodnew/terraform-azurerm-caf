global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "google-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "google-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_identity_provider_google = {
  google = {
    client_id = "00000000.apps.googleusercontent.com"
    # Configure Google OAuth consent/redirects and inject its secret securely.
    client_secret  = "REPLACE-WITH-SECURE-INPUT"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
