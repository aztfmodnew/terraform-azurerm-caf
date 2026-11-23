global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "api-versions", region = "primary" }
}
api_management = {
  gateway = {
    name           = "api-versions", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}

api_management_api_version_set = {
  orders = {
    name              = "orders-versions"
    display_name      = "Order APIs"
    versioning_scheme = "Segment"
    api_management    = { key = "gateway" }
    resource_group    = { key = "gateway" }
  }
}
