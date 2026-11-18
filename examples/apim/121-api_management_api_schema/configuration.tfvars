global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "api-schema", region = "primary" }
}
api_management = {
  gateway = {
    name           = "api-schema", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
api_management_api = {
  orders = {
    name     = "orders", api_management = { key = "gateway" }, resource_group = { key = "gateway" }
    revision = "1", api_type = "http", display_name = "Orders", path = "orders", protocols = ["https"]
  }
}

api_management_api_schema = {
  order = {
    schema_id      = "order-schema"
    content_type   = "application/vnd.oai.openapi.components+json"
    components     = "{\"schemas\":{\"Order\":{\"type\":\"object\",\"properties\":{\"id\":{\"type\":\"string\"}}}}}"
    api            = { key = "orders" }
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
