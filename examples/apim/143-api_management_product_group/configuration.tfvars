global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "product-group", region = "primary" }
}
api_management = {
  gateway = {
    name           = "product-group", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
api_management_group = {
  consumers = {
    name           = "consumers", display_name = "API consumers", type = "custom"
    api_management = { key = "gateway" }, resource_group = { key = "gateway" }
  }
}
api_management_product = {
  standard = {
    product_id     = "standard", display_name = "Standard APIs", subscription_required = false, published = true
    api_management = { key = "gateway" }, resource_group = { key = "gateway" }
  }
}

api_management_product_group = {
  consumers = {
    group          = { key = "consumers" }
    product        = { key = "standard" }
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
