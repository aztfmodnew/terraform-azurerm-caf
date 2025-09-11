global_settings = {
  default_region = "region1"
  inherit_tags   = true
  regions = {
    region1 = "westeurope"
  }
  prefixes = ["caf"]
  use_slug = true
}

tags = {
  example     = "azure-bot"
  landingzone = "examples"
}

resource_groups = {
  bot_rg = {
    name   = "azure-bot-rg"
    region = "region1"
  }
}

azure_bots = {
  example_bot = {
    name               = "example-chatbot"
    resource_group_key = "bot_rg"
    microsoft_app_id   = "12345678-1234-1234-1234-123456789012"
    sku                = "F0"

    # Optional configurations
    display_name                  = "Example ChatBot"
    endpoint                      = "https://example.com/api/messages"
    icon_url                      = "https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png"
    microsoft_app_tenant_id       = "87654321-4321-4321-4321-210987654321"
    microsoft_app_type            = "SingleTenant"
    local_authentication_enabled  = true
    public_network_access_enabled = true
    streaming_endpoint_enabled    = false

    # MS Teams Channel Integration
    ms_teams_channels = {
      teams_channel = {
        name                   = "teams-integration"
        enable_calling         = false
        deployment_environment = "CommercialDeployment"
        # calling_web_hook     = "https://example.com/webhook/teams"  # Optional: webhook for calls
      }
    }

    tags = {
      service     = "chatbot"
      purpose     = "demo"
      environment = "example"
    }
  }
}
