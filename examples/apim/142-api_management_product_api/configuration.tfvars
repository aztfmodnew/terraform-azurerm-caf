global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "product-api", region = "primary" }
}
api_management = {
  gateway = {
    name           = "product-api", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
api_management_api = {
  orders = {
    name     = "orders", api_management = { key = "gateway" }, resource_group = { key = "gateway" }
    revision = "1", api_type = "http", display_name = "Orders", path = "orders", protocols = ["https"]
  }
}
api_management_product = {
  standard = {
    product_id     = "standard", display_name = "Standard APIs", subscription_required = false, published = true
    api_management = { key = "gateway" }, resource_group = { key = "gateway" }
  }
}

api_management_product_api = {
  orders = {
    api            = { key = "orders" }
    product        = { key = "standard" }
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
