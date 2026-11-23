global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "tag-description", region = "primary" }
}
api_management = {
  gateway = {
    name           = "tag-description", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
api_management_api = {
  orders = {
    name     = "orders", api_management = { key = "gateway" }, resource_group = { key = "gateway" }
    revision = "1", api_type = "http", display_name = "Orders", path = "orders", protocols = ["https"]
  }
}
api_management_tag = {
  orders = {
    name = "orders", display_name = "Order APIs", api_management = { key = "gateway" }
  }
}
api_management_api_tag = {
  orders = {
    api = { key = "orders" }, tag = { key = "orders" }
  }
}

api_management_api_tag_description = {
  orders = {
    api_tag                            = { key = "orders" }
    description                        = "Order lifecycle operations."
    external_documentation_url         = "https://example.com/orders"
    external_documentation_description = "Order API documentation."
  }
}
