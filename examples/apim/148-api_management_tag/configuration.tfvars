global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "service-tag", region = "primary" }
}
api_management = {
  gateway = {
    name           = "service-tag", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}

api_management_tag = {
  orders = {
    name           = "orders"
    display_name   = "Order APIs"
    api_management = { key = "gateway" }
  }
}
