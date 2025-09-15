# Application Gateway Applications Configuration for Azure Bot
application_gateway_applications = {
  bot_app = {
    application_gateway_key = "secure_bot_appgw"
    name                    = "secure-bot-application"

    # Listeners Configuration
    listeners = {
      # HTTP Listener (will redirect to HTTPS)
      http_listener = {
        name                           = "secure-bot-http-listener"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "http"
        protocol                       = "Http"
        host_name                      = "secure-bot.example.com" # Replace with your domain
      },

      # HTTPS Listener (main listener for bot traffic)
      https_listener = {
        name                           = "secure-bot-https-listener"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "https"
        protocol                       = "Https"
        host_name                      = "secure-bot.example.com" # Replace with your domain
        # ssl_certificate_key            = "bot_ssl_cert"  # Uncomment when using custom SSL
      }
    }

    # Request Routing Rules
    request_routing_rules = {
      # HTTP to HTTPS Redirect Rule
      http_redirect = {
        name         = "http-to-https-redirect"
        rule_type    = "Basic"
        priority     = 100
        listener_key = "http_listener"
        redirect_configuration = {
          redirect_type        = "Permanent"
          target_listener_key  = "https_listener"
          include_path         = true
          include_query_string = true
        }
      },

      # Main HTTPS Routing Rule to Bot Backend
      https_routing = {
        name             = "https-to-bot-backend"
        rule_type        = "PathBasedRouting"
        priority         = 200
        listener_key     = "https_listener"
        url_path_map_key = "bot_path_routing"
      }
    }

    # URL Path Maps for Advanced Routing
    url_path_maps = {
      bot_path_routing = {
        name                              = "bot-path-routing"
        default_backend_address_pool_key  = "bot_backend"
        default_backend_http_settings_key = "bot_https_settings"

        # Specific path rules for bot endpoints
        path_rules = {
          # Bot Framework Messages API
          api_messages = {
            name                      = "api-messages-rule"
            paths                     = ["/api/messages", "/api/messages/*"]
            backend_address_pool_key  = "bot_backend"
            backend_http_settings_key = "bot_https_settings"
          },

          # Health Check Endpoint
          health_check = {
            name                      = "health-check-rule"
            paths                     = ["/api/health", "/health", "/status"]
            backend_address_pool_key  = "bot_backend"
            backend_http_settings_key = "bot_https_settings"
          },

          # Bot DirectLine API
          directline_api = {
            name                      = "directline-api-rule"
            paths                     = ["/v3/directline/*", "/directline/*"]
            backend_address_pool_key  = "bot_backend"
            backend_http_settings_key = "bot_https_settings"
          },

          # Web Chat Interface (if hosting web chat)
          webchat = {
            name                      = "webchat-rule"
            paths                     = ["/webchat", "/webchat/*", "/chat", "/chat/*"]
            backend_address_pool_key  = "bot_backend"
            backend_http_settings_key = "bot_https_settings"
          }
        }
      }
    }

    # Backend Address Pools
    backend_address_pools = {
      bot_backend = {
        name = "secure-bot-backend-pool"
        # Backend addresses pointing to the Bot Service private endpoint
        backend_addresses = {
          bot_private_endpoint = {
            ip_address = "10.100.2.10" # Private IP of the bot service private endpoint
          }
        }
        # Alternative: Use FQDN if private DNS is configured
        # fqdns = ["secure-chatbot-waf-pe.privatelink.directline.botframework.com"]
      }
    }

    # Backend HTTP Settings
    backend_http_settings = {
      bot_https_settings = {
        name                           = "secure-bot-https-settings"
        cookie_based_affinity          = "Disabled"
        affinity_cookie_name           = "ApplicationGatewayAffinity"
        path                           = "/"
        port                           = 443
        protocol                       = "Https"
        request_timeout                = 60
        host_name_from_backend_address = false
        host_name                      = "secure-chatbot-waf-pe.directline.botframework.com"

        # Connection draining for graceful shutdowns
        connection_draining = {
          enabled           = true
          drain_timeout_sec = 30
        }

        # Health probe configuration
        probe_key = "bot_health_probe"
      }
    }

    # Health Probes
    probes = {
      bot_health_probe = {
        name                                = "secure-bot-health-probe"
        protocol                            = "Https"
        host                                = "secure-chatbot-waf-pe.directline.botframework.com"
        port                                = 443
        path                                = "/api/health"
        interval                            = 30
        timeout                             = 30
        unhealthy_threshold                 = 3
        pick_host_name_from_backend_address = false
        minimum_servers                     = 0

        # Match conditions for successful health checks
        match = {
          status_codes = ["200-399"]
          body         = "" # Can specify expected response body
        }
      }
    }

    # WAF Policy Association
    firewall_policy_key = "bot_waf_policy"

    # Custom Error Pages (optional)
    custom_error_configurations = {
      error_403 = {
        status_code           = "HttpStatus403"
        custom_error_page_url = "https://secure-bot.example.com/error/403.html"
      },
      error_502 = {
        status_code           = "HttpStatus502"
        custom_error_page_url = "https://secure-bot.example.com/error/502.html"
      }
    }

    # SSL Configuration (when using custom certificates)
    # ssl_certificates = {
    #   bot_ssl_cert = {
    #     name                = "secure-bot-ssl-certificate"
    #     key_vault_secret_id = "https://secure-bot-kv.vault.azure.net/secrets/bot-ssl-cert/latest"
    #   }
    # }

    # Trusted Root Certificates (if backend uses custom CA)
    # trusted_root_certificates = {
    #   bot_root_ca = {
    #     name = "bot-root-ca"
    #     data = "base64-encoded-root-certificate"
    #   }
    # }

    # Global Application Gateway Settings
    settings = {
      enable_http2               = true
      max_request_body_size      = 128 # KB
      request_buffering_enabled  = true
      response_buffering_enabled = false

      # Force tunnel for outbound connections
      force_firewall_policy_association = true
    }

    tags = {
      service     = "application-gateway-app"
      purpose     = "secure-bot-routing"
      environment = "production"
      security    = "waf-protected"
    }
  }
}
