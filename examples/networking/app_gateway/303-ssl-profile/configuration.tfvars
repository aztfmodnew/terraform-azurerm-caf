global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  agw_region1 = {
    name   = "example-agw"
    region = "region1"
  }
}

private_dns = {
  agw_internal = {
    name               = "app-gateway.internal"
    resource_group_key = "agw_region1"
    vnet_links = {
      app_gateway = {
        name     = "app-gateway-vnet"
        vnet_key = "vnet_region1"
      }
    }
  }
}