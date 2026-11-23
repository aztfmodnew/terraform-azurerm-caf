global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "user-notification-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "user-notification-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_user = {
  operator = {
    user_id        = "operations-user"
    first_name     = "API"
    last_name      = "Operator"
    email          = "operator@example.com"
    state          = "active"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
api_management_notification_recipient_user = {
  operations = {
    notification_type = "AccountClosedPublisher"
    api_management    = { key = "gateway" }
    user              = { key = "operator" }
  }
}
