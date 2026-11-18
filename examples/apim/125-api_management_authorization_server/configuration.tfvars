global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "oauth-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "oauth-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_authorization_server = {
  oauth = {
    name                         = "partner-oauth"
    display_name                 = "Partner OAuth"
    authorization_endpoint       = "https://login.example.com/authorize"
    authorization_methods        = ["GET", "POST"]
    client_id                    = "00000000-0000-0000-0000-000000000001"
    client_registration_endpoint = "https://login.example.com/register"
    grant_types                  = ["authorizationCode"]
    api_management               = { key = "gateway" }
    resource_group               = { key = "gateway" }
  }
}
