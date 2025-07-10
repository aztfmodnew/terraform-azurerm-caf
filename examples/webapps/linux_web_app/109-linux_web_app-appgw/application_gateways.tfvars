application_gateways = {
  appgw = {
    resource_group_key = "webapp_appgw"
    name               = "appgw"
    vnet_key           = "webapp_appgw"
    subnet_key         = "appgw"
    sku = {
      name     = "Standard_v2"
      tier     = "Standard_v2"
      capacity = 2
    }

    frontend_ports = {
      port_80 = {
        name = "port-80"
        port = 80
      }
    }

    frontend_ip_configurations = {
      public = {
        name                 = "public"
        public_ip_key        = "pip_appgw"
        public_ip_address_id = null
      }
    }

    backend_address_pools = {
      app1 = {
        name = "app1"
      }
    }

    backend_http_settings = {
      port_80 = {
        name                  = "port-80"
        cookie_based_affinity = "Disabled"
        path                  = "/"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 60
      }
    }

    http_listeners = {
      listener_80 = {
        name                           = "listener-80"
        frontend_ip_configuration_name = "public"
        frontend_port_name             = "port-80"
        protocol                       = "Http"
      }
    }

    request_routing_rules = {
      rule_80 = {
        name                       = "rule-80"
        rule_type                  = "Basic"
        http_listener_name         = "listener-80"
        backend_address_pool_name  = "app1"
        backend_http_settings_name = "port-80"
      }
    }
  }
}
