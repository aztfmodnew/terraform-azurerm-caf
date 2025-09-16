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

    # Enable WAF Policy
    waf_policy_key = "bot_waf_policy"

    # Frontend IP Configurations
    front_end_ip_configurations = {
      public = {
        name          = "public"
        public_ip_key = "appgw_pip"
      }
    }

    # Frontend Ports
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

    # Global Settings
    enable_http2 = true
    zones        = ["1", "2", "3"]

    # Redirect Configurations
    redirect_configurations = {
      http-to-https = {
        name                 = "http-to-https"
        redirect_type        = "Permanent"
        target_listener_name = "secure-bot-https-listener"
        include_path         = true
        include_query_string = true
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
