global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  gateway = {
    name   = "product-policy-example"
    region = "region1"
  }
}

api_management = {
  gateway = {
    name            = "product-policy-example"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "gateway@example.com"
    sku_name        = "Developer_1"
  }
}

api_management_product = {
  gateway = {
    product_id     = "example-product"
    display_name   = "Example Product"
    published      = true
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}

api_management_product_policy = {
  gateway = {
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
    product        = { key = "gateway" }
    xml_content    = "<policies><inbound><base /></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>"
  }
}
