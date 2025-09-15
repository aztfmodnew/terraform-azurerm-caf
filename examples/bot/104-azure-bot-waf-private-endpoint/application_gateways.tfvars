# Application Gateway Configuration for Azure Bot with WAF Protection
application_gateways = {
  secure_bot_appgw = {
    resource_group_key = "networking_rg"
    name               = "secure-bot-appgw"
    vnet_key           = "secure_vnet"
    subnet_key         = "appgw_subnet"
    sku_name           = "WAF_v2"
    sku_tier           = "WAF_v2"

    # Autoscaling Configuration
    capacity = {
      autoscale = {
        minimum_scale_unit = 1
        maximum_scale_unit = 3
      }
    }

    # Enable WAF
    waf_configuration = {
      firewall_mode    = "Prevention"
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"
      enabled          = true
      waf_policy_key   = "bot_waf_policy"
    }

    # Frontend IP Configurations
    front_end_ip_configurations = {
      public = {
        name          = "public-frontend"
        public_ip_key = "appgw_pip"
      }
    }

    # Frontend Ports
    front_end_ports = {
      80 = {
        name     = "http-port"
        port     = 80
        protocol = "Http"
      },
      443 = {
        name     = "https-port"
        port     = 443
        protocol = "Https"
      }
    }

    # Backend Address Pools
    backend_address_pools = {
      bot_backend = {
        name  = "secure-bot-backend-pool"
        fqdns = ["secure-bot.example.com"]
      }
    }

    # Backend HTTP Settings
    backend_http_settings = {
      bot_settings = {
        name                                = "secure-bot-backend-settings"
        cookie_based_affinity               = "Disabled"
        path                                = "/api/messages/"
        port                                = 443
        protocol                            = "Https"
        request_timeout                     = 60
        probe_name                          = "bot-health-probe"
        pick_host_name_from_backend_address = true
      }
    }

    # Health Probes
    probes = {
      bot_health_probe = {
        name                                      = "bot-health-probe"
        protocol                                  = "Https"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = true
        minimum_servers                           = 0
        match = {
          status_code = ["200-399"]
        }
      }
    }

    # HTTP Listeners
    http_listeners = {
      bot_listener = {
        name                            = "secure-bot-listener"
        front_end_ip_configuration_name = "public-frontend"
        front_end_port_name             = "https-port"
        protocol                        = "Https"
        require_sni                     = false
      }
    }

    # Request Routing Rules
    request_routing_rules = {
      bot_rule = {
        name                       = "secure-bot-routing-rule"
        rule_type                  = "Basic"
        http_listener_name         = "secure-bot-listener"
        backend_address_pool_name  = "secure-bot-backend-pool"
        backend_http_settings_name = "secure-bot-backend-settings"
        priority                   = 1
      }
    }

    tags = {
      architecture = "secure-bot"
      environment  = "production"
      cost_center  = "it-security"
      service      = "waf-protection"
      purpose      = "bot-security"
      example      = "azure-bot-waf-private-endpoint"
      landingzone  = "examples"
    }
  }
}
