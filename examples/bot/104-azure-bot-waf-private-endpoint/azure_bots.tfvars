# Azure Bot Service Configuration
azure_bots = {
  secure_bot = {
    name               = "secure-chatbot-waf-pe"
    resource_group_key = "bot_rg"
    microsoft_app_id   = "12345678-1234-1234-1234-123456789012"
    sku                = "S1" # S1 required for private endpoints

    # Bot Configuration
    display_name                  = "Secure ChatBot with WAF and Private Endpoint"
    endpoint                      = "https://secure-bot-endpoint.example.com/api/messages"
    icon_url                      = "https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png"
    microsoft_app_tenant_id       = "87654321-4321-4321-4321-210987654321"
    microsoft_app_type            = "SingleTenant"
    local_authentication_enabled  = true
    public_network_access_enabled = false # Private endpoint only
    streaming_endpoint_enabled    = false

    # Private Endpoint Configuration
    private_endpoints = {
      bot_pe = {
        name               = "secure-bot-pe"
        vnet_key           = "secure_vnet"
        subnet_key         = "private_endpoints"
        resource_group_key = "networking_rg"

        tags = {
          networking = "private endpoint"
          service    = "bot"
          security   = "high"
        }

        private_service_connection = {
          name                 = "secure-bot-pe-connection"
          is_manual_connection = false
          subresource_names    = ["bot"]
        }

        private_dns = {
          zone_group_name = "privatelink.directline.botframework.com"
          keys            = ["bot_dns"]
        }
      }
    }

    # Microsoft Teams Channel Integration
    ms_teams_channels = {
      teams_channel = {
        name                   = "secure-teams-integration"
        enable_calling         = false
        deployment_environment = "CommercialDeployment"
      }
    }

    # Web Chat Channel (for Application Gateway integration)
    web_chat_channels = {
      web_chat = {
        name       = "secure-web-chat"
        site_names = ["AppGateway", "WebPortal"]
      }
    }

    tags = {
      service     = "chatbot"
      purpose     = "secure-bot-with-waf"
      environment = "production"
      compliance  = "required"
    }
  }
}
