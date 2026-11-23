global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  gateway = {
    name   = "ai-gateway"
    region = "region1"
  }
}

api_management = {
  gateway = {
    name   = "ai-gateway"
    region = "region1"
    resource_group = {
      key = "gateway"
    }
    publisher_name  = "Example"
    publisher_email = "gateway@example.com"
    sku_name        = "Developer_1"
  }
}

api_management_named_value = {
  backend_endpoint = {
    name         = "backend-endpoint"
    display_name = "backend-endpoint"
    value        = "https://example.com"
    tags         = ["ai-gateway"]
    resource_group = {
      key = "gateway"
    }
    api_management = {
      key = "gateway"
    }
  }
}
