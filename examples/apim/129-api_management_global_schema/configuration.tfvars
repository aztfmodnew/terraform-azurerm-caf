global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "global-schema", region = "primary" }
}
api_management = {
  gateway = {
    name           = "global-schema", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}

api_management_global_schema = {
  order = {
    schema_id      = "order-schema"
    type           = "json"
    value          = "{\"type\":\"object\",\"properties\":{\"id\":{\"type\":\"string\"}}}"
    description    = "Reusable order payload."
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
