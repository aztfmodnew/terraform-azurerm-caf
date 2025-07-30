application_gateway_applications = {
  webapp_app = {
    application_gateway_key = "appgw"
    name                    = "webapp-app"

    listeners = {
      public = {
        name                           = "webapp-listener-80"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "80"
        request_routing_rule_key       = "basic_rule"
      }
    }

    request_routing_rules = {
      basic_rule = {
        rule_type = "Basic"
        priority  = 100
      }
    }

    backend_http_setting = {
      port                                = 80
      protocol                            = "Http"
      cookie_based_affinity               = "Disabled"
      path                                = "/"
      request_timeout                     = 60
      pick_host_name_from_backend_address = true
    }

    backend_pool = {
      fqdns = [
        # This will be populated by the web app FQDN
        # "mywebapp.azurewebsites.net"
      ]
    }
  }
}
