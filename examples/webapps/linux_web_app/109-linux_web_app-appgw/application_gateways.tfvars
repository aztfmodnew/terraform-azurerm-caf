application_gateways = {
  appgw = {
    resource_group_key = "webapp_appgw"
    name               = "appgw"
    vnet_key           = "webapp_appgw"
    subnet_key         = "appgw"
    sku_name           = "Standard_v2"
    sku_tier           = "Standard_v2"
    capacity = {
      autoscale = {
        minimum_scale_unit = 1
        maximum_scale_unit = 10
      }
    }

    front_end_ports = {
      80 = {
        name     = "http"
        port     = 80
        protocol = "Http"
      }
      443 = {
        name     = "https"
        port     = 443
        protocol = "Https"
      }
    }

    front_end_ip_configurations = {
      public = {
        name          = "public"
        public_ip_key = "pip_appgw"
      }
    }
  }
}
