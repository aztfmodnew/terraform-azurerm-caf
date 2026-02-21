global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  rg1 = {
    name   = "notification-hub"
    region = "region1"
  }
}

messaging = {
  notification_hub_namespaces = {
    ns1 = {
      name           = "example-nh-namespace"
      namespace_type = "NotificationHub"
      sku_name       = "Free"
      resource_group = {
        key = "rg1"
      }
      region = "region1"
      hubs = {
        hub1 = {
          name = "example-hub"
        }
      }
    }
  }
}
