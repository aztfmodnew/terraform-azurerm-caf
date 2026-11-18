global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "product-tag", region = "primary" }
}
api_management = {
  gateway = {
    name           = "product-tag", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
api_management_product = {
  standard = {
    product_id     = "standard", display_name = "Standard APIs", subscription_required = false, published = true
    api_management = { key = "gateway" }, resource_group = { key = "gateway" }
  }
}
api_management_tag = {
  orders = {
    name = "orders", display_name = "Order APIs", api_management = { key = "gateway" }
  }
}

api_management_product_tag = {
  orders = {
    product        = { key = "standard" }
    tag            = { key = "orders" }
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
