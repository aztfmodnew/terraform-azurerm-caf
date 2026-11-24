global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  ai_services = {
    name = "ai-services-private"
  }
  networking = {
    name = "ai-services-network"
  }
}

vnets = {
  ai_services = {
    resource_group_key = "networking"
    vnet = {
      name          = "ai-services"
      address_space = ["10.20.0.0/16"]
    }
  }
}

virtual_subnets = {
  ai_private_endpoints = {
    name                              = "ai-private-endpoints"
    cidr                              = ["10.20.1.0/24"]
    private_endpoint_network_policies = "Disabled"
    vnet = {
      key = "ai_services"
    }
  }
}

private_dns = {
  cognitive_services = {
    name               = "privatelink.cognitiveservices.azure.com"
    resource_group_key = "networking"
    vnet_links = {
      ai_services = {
        name     = "ai-services"
        vnet_key = "ai_services"
      }
    }
  }
  openai = {
    name               = "privatelink.openai.azure.com"
    resource_group_key = "networking"
    vnet_links = {
      ai_services = {
        name     = "ai-services"
        vnet_key = "ai_services"
      }
    }
  }
  services_ai = {
    name               = "privatelink.services.ai.azure.com"
    resource_group_key = "networking"
    vnet_links = {
      ai_services = {
        name     = "ai-services"
        vnet_key = "ai_services"
      }
    }
  }
}

ai_services = {
  ai_gateway_backend = {
    name                          = "ai-gateway-backend"
    sku_name                      = "S0"
    custom_subdomain_name         = "ai-gateway-backend"
    local_auth_enabled            = false
    public_network_access_enabled = false
    resource_group = {
      key = "ai_services"
    }
    network_acls = {
      default_action = "Deny"
    }
    private_endpoints = {
      account = {
        name       = "ai-services-account"
        vnet_key   = "ai_services"
        subnet_key = "ai_private_endpoints"
        private_service_connection = {
          name                 = "ai-services-account"
          is_manual_connection = false
        }
        private_dns = {
          zone_group_name = "ai-services"
          keys            = ["cognitive_services", "openai", "services_ai"]
        }
      }
    }
  }
}

managed_identities = {
  ai_gateway_operator = {
    name               = "ai-gateway-operator"
    resource_group_key = "ai_services"
  }
}

api_management = {
  ai_gateway = {
    name            = "ai-gateway"
    region          = "region1"
    publisher_name  = "AI Gateway"
    publisher_email = "owner@example.com"
    sku_name        = "Developer_1"
    resource_group = {
      key = "ai_services"
    }
    identity = {
      type = "SystemAssigned"
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    ai_services = {
      ai_gateway_backend = {
        "Cognitive Services OpenAI User" = {
          # Resolve the APIM managed identity from the APIM module.
          api_management = {
            keys = ["ai_gateway"]
          }
          # Resolve a separate user-assigned managed identity by key.
          managed_identities = {
            keys = ["ai_gateway_operator"]
          }
          # Resolve the principal running Terraform without hardcoding an object ID.
          logged_in = {
            keys = ["user"]
          }
        }
      }
    }
  }
}
