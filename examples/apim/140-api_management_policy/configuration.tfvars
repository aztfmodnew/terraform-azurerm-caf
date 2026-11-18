global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "service-policy", region = "primary" }
}
api_management = {
  gateway = {
    name           = "service-policy", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}

# A service has one global policy. Do not manage it from another module/state.
api_management_policy = {
  global = {
    api_management = { key = "gateway" }
    xml_content    = "<policies><inbound/><backend><forward-request/></backend><outbound/><on-error/></policies>"
  }
}
