# Application Gateway application configuration
# This file defines the listeners, routing rules, backend pools, and probes consumed by the CAF module,
# following the established functional example pattern and Microsoft guidance.

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
        # Reference Key Vault certificate
        keyvault_certificate = {
          certificate_key = "app_example_com"
        }
      }
    }

    # Request Routing Rules
    request_routing_rules = {
      https_routing = {
        rule_type = "Basic"
        priority  = 200
        # Module automatically associates backend pool and http settings based on application name
      }
    }

    # Backend HTTP Settings
    backend_http_setting = {
      # No name - module uses application name automatically
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
      # No name - module uses application name automatically
      # Dynamic resolution of Storage Account Private Endpoint IP
      storage_accounts = {
        static_website = {
          key                  = "demo_static_website"
          private_endpoint_key = "backend_pe" # Matches the PE key defined in storage_account_static_website.tfvars
        }
      }
      # Fallback: static IPs can still be provided if needed
      # ip_addresses = ["10.200.20.10"]
    }

    # Health Probe
    probes = {
      https_health_probe = {
        name                                      = "probe-https-health"
        protocol                                  = "Https"
        path                                      = "/"
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

  # HTTP to HTTPS Redirect
  http_redirect = {
    name                    = "http-redirect"
    type                    = "redirect"
    application_gateway_key = "production_appgw"

    listeners = {
      http_listener = {
        name                           = "listener-http-80"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "http"
        protocol                       = "Http"
        host_name                      = "app.example.com"
        request_routing_rule_key       = "redirect_rule"
      }
    }

    request_routing_rules = {
      redirect_rule = {
        rule_type                   = "Basic"
        priority                    = 100
        redirect_configuration_name = "http-to-https"
      }
    }
  }
}
