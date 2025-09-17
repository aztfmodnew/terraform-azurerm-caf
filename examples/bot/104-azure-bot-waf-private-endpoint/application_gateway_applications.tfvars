# Application Gateway Applications Configuration for Azure Bot
application_gateway_applications = {
  secure_bot_app = {
    name                    = "secure-bot-application"
    application_gateway_key = "secure_bot_appgw"

    # HTTP Listeners
    listeners = {
      bot_https_listener = {
        name                           = "secure-bot-https-listener"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "443"
        protocol                       = "Https"
        require_sni                    = false
        request_routing_rule_key       = "bot_https_rule"
        keyvault_certificate = {
          certificate_key = "secure-bot-endpoint.example.com"
        }
      }
    }

    # Request Routing Rules
    request_routing_rules = {
      bot_https_rule = {
        rule_type = "Basic"
        priority  = 100
      }
    }

    # Backend HTTP Settings (singular)
    backend_http_setting = {
      port                                      = 443
      protocol                                  = "Https"
      cookie_based_affinity                     = "Disabled"
      path                                      = "/api/messages/"
      request_timeout                           = 60
      pick_host_name_from_backend_http_settings = true
    }

    # Backend Pool (singular)
    backend_pool = {
      fqdns = ["secure-bot-endpoint.example.com"]
    }

    tags = {
      architecture = "secure-bot"
      environment  = "production"
      cost_center  = "it-security"
      service      = "bot-application"
      purpose      = "bot-routing"
      example      = "azure-bot-waf-private-endpoint"
      landingzone  = "examples"
    }
  }

  # Redirect HTTP to HTTPS
  redirect_https = {
    name                    = "redirect-https"
    type                    = "redirect"
    application_gateway_key = "secure_bot_appgw"

    listeners = {
      redirect_http = {
        name                           = "secure-bot-redirect-listener"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "80"
        protocol                       = "Http"
        request_routing_rule_key       = "redirect_rule"
      }
    }

    request_routing_rules = {
      redirect_rule = {
        rule_type                   = "Basic"
        redirect_configuration_name = "http-to-https"
        priority                    = 300
      }
    }
  }
}
