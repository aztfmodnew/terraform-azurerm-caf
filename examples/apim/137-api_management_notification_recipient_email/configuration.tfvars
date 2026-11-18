global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "notification-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "notification-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_notification_recipient_email = {
  operations = {
    email             = "operations@example.com"
    notification_type = "AccountClosedPublisher"
    api_management    = { key = "gateway" }
  }
}
