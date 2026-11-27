global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 4
}

resource_groups = {
  ai_gateway_foundry = {
    name = "ai-gateway-foundry"
  }
}

managed_identities = {
  foundry_project = {
    name               = "foundry-project"
    resource_group_key = "ai_gateway_foundry"
  }
}

log_analytics = {
  ai_gateway_foundry = {
    name               = "ai-gateway-foundry"
    resource_group_key = "ai_gateway_foundry"
    region             = "region1"
    sku                = "PerGB2018"
    retention_in_days  = 30
  }
}

diagnostics_destinations = {
  log_analytics = {
    ai_gateway_foundry = {
      log_analytics_key = "ai_gateway_foundry"
    }
  }
}

diagnostics_definition = {
  ai_services = {
    name = "ai-services-operational-logs"
    categories = {
      log = [
        ["Audit", true, false, 0]
      ]
      metric = [
        ["AllMetrics", true, false, 0]
      ]
    }
  }
}

ai_services = {
  ai_gateway_foundry = {
    name                       = "ai-gateway-foundry"
    resource_group_key         = "ai_gateway_foundry"
    sku_name                   = "S0"
    custom_subdomain_name      = "ai-gateway-foundry-platform"
    project_management_enabled = true
    local_auth_enabled         = false
    identity = {
      type = "SystemAssigned"
    }
    diagnostic_profiles = {
      platform = {
        definition_key   = "ai_services"
        destination_type = ["log_analytics"]
        destination_key  = "ai_gateway_foundry"
      }
    }
  }
}

cognitive_account_project = {
  ai_gateway = {
    name                  = "ai-gateway"
    display_name          = "AI Gateway"
    description           = "Foundry project for the AI gateway platform."
    cognitive_account_key = "ai_gateway_foundry"
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["foundry_project"]
    }
  }
}

cognitive_deployment = {
  chat = {
    name                       = "chat"
    cognitive_account_key      = "ai_gateway_foundry"
    dynamic_throttling_enabled = true
    model = {
      format  = "OpenAI"
      name    = "gpt-4o"
      version = "2024-08-06"
    }
    sku = {
      name     = "GlobalStandard"
      capacity = 1
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    ai_services = {
      ai_gateway_foundry = {
        "Cognitive Services OpenAI User" = {
          managed_identities = {
            keys = ["foundry_project"]
          }
        }
      }
    }
  }
}
