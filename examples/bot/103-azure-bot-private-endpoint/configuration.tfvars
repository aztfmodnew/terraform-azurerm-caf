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
  example     = "azure-bot-private-endpoint"
  landingzone = "examples"
}

resource_groups = {
  bot_rg = {
    name   = "azure-bot-pe-rg"
    region = "region1"
  }
}

azure_bots = {
  example_bot = {
    name               = "example-chatbot-pe"
    resource_group_key = "bot_rg"
    microsoft_app_id   = "12345678-1234-1234-1234-123456789012"
    sku                = "S1" # S1 supports private endpoints

    # Optional configurations
    display_name                  = "Example ChatBot with Private Endpoint"
    endpoint                      = "https://example.com/api/messages"
    icon_url                      = "https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png"
    microsoft_app_tenant_id       = "87654321-4321-4321-4321-210987654321"
    microsoft_app_type            = "SingleTenant"
    local_authentication_enabled  = true
    public_network_access_enabled = false # Disable public access when using private endpoint
    streaming_endpoint_enabled    = false

    # Private Endpoint Configuration
    private_endpoints = {
      pe1 = {
        name               = "bot-pe1"
        vnet_key           = "vnet1"
        subnet_key         = "private_endpoints"
        resource_group_key = "bot_rg"

        tags = {
          networking = "private endpoint"
          service    = "bot"
        }

        private_service_connection = {
          name                 = "bot-pe1"
          is_manual_connection = false
          subresource_names    = ["bot"]
        }

        private_dns = {
          zone_group_name = "privatelink.directline.botframework.com"
          keys            = ["bot_dns"]
        }
      }
    }

    # MS Teams Channel Integration
    ms_teams_channels = {
      teams_channel = {
        name                   = "teams-integration"
        enable_calling         = false
        deployment_environment = "CommercialDeployment"
      }
    }

    tags = {
      service     = "chatbot"
      purpose     = "demo-private-endpoint"
      environment = "example"
    }
  }
}

# Virtual Network Configuration
vnets = {
  vnet1 = {
    resource_group_key = "bot_rg"
    vnet = {
      name          = "bot-vnet"
      address_space = ["172.34.0.0/16"]
    }
  }
}

# Subnet Configuration
virtual_subnets = {
  subnet1 = {
    name    = "bot-subnet"
    cidr    = ["172.34.1.0/24"]
    nsg_key = "empty_nsg"
    vnet = {
      key = "vnet1"
    }
  },
  private_endpoints = {
    name                              = "private-endpoint-subnet"
    cidr                              = ["172.34.2.0/24"]
    private_endpoint_network_policies = "Enabled"
    vnet = {
      key = "vnet1"
    }
  }
}

# Network Security Group Definition
network_security_group_definition = {
  empty_nsg = {
    nsg = []
  }
}

# Private DNS Configuration for Bot Service
private_dns = {
  bot_dns = {
    name               = "privatelink.directline.botframework.com"
    resource_group_key = "bot_rg"

    tags = {
      resource = "private dns"
      service  = "bot"
    }

    vnet_links = {
      vnlk1 = {
        name     = "bot-vnet-link"
        vnet_key = "vnet1"
        tags = {
          net_team = "bot-team"
        }
      }
    }
  }
}
