# Application Gateway Applications Configuration
# Este fichero define los listeners, reglas, pools y settings requeridos por el módulo CAF
# siguiendo el patrón de los ejemplos funcionales y la documentación oficial.

application_gateway_applications = {
  cngfw_app = {
    name                    = "cngfw-app"
    application_gateway_key = "production_appgw"

    # Listeners
    listeners = {
      https_listener = {
        name                           = "listener-https-443"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "https"
        protocol                       = "Https"
        host_name                      = "app.example.com"
        require_sni                    = true
        request_routing_rule_key       = "https_routing"
      }
      http_listener = {
        name                           = "listener-http-80"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "http"
        protocol                       = "Http"
        host_name                      = "app.example.com"
        request_routing_rule_key       = "http_to_https_redirect"
      }
    }

    # Request Routing Rules
    request_routing_rules = {
      http_to_https_redirect = {
        rule_type                   = "Basic"
        priority                    = 100
        redirect_configuration_name = "http-to-https"
      }
      https_routing = {
        rule_type                 = "Basic"
        priority                  = 200
        backend_address_pool_key  = "backend-pool-via-cngfw"
        backend_http_settings_key = "backend-http-settings-443"
      }
    }

    # Backend HTTP Settings
    backend_http_setting = {
      name                                = "backend-http-settings-443"
      cookie_based_affinity               = "Disabled"
      affinity_cookie_name                = "ApplicationGatewayAffinity"
      port                                = 443
      protocol                            = "Https"
      request_timeout                     = 30
      pick_host_name_from_backend_address = false
      host_name                           = "app.example.com"
      connection_draining = {
        enabled           = true
        drain_timeout_sec = 60
      }
      probe_key = "https_health_probe"
    }

    # Backend Pool
      backend_pool = {
        name         = "backend-pool-via-cngfw"
        ip_addresses = ["10.200.20.10"] # IP dummy
          # TODO: The backend pool IP is currently static (10.200.20.10).
          # Pending: Implement dynamic resolution of the Private Endpoint private IP like in CNGFW module
          # so Application Gateway can consume it automatically from module outputs.
      }

    # Health Probe
    probes = {
      https_health_probe = {
        name                                      = "probe-https-health"
        protocol                                  = "Https"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "app.example.com"
        match = {
          status_code = ["200-399"]
          body        = ""
        }
      }
    }

    tags = {
      environment = "production"
      tier        = "frontend"
      protection  = "waf-enabled"
      ha          = "zone-redundant"
      cost_center = "infrastructure"
    }
  }
}
