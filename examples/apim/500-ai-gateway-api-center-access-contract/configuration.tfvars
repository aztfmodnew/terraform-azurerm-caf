global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 0
  passthrough    = true
  use_slug       = false
}

resource_groups = {
  ai_gateway = {
    name = "rg-ai-gateway-access-contract"
  }
}

managed_identities = {
  gateway = {
    name               = "id-ai-gateway"
    resource_group_key = "ai_gateway"
  }
}

api_management = {
  ai_gateway = {
    name            = "apim-ai-gateway"
    region          = "region1"
    publisher_name  = "AI Platform"
    publisher_email = "owner@example.invalid"
    sku_name        = "Developer_1"
    resource_group  = { key = "ai_gateway" }
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["gateway"]
    }
  }
}

api_management_api = {
  ai_chat = {
    name           = "ai-chat"
    display_name   = "AI Chat API"
    revision       = "1"
    path           = "ai/chat"
    protocols      = ["https"]
    service_url    = "https://placeholder.example.invalid"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
  }
}

api_management_ai_backend = {
  ai_primary = {
    name             = "ai-primary"
    endpoint         = "https://ai-primary.example.invalid"
    api_management   = { key = "ai_gateway" }
    resource_group   = { key = "ai_gateway" }
    managed_identity = { key = "gateway" }
  }
}

api_management_backend_pool = {
  ai_chat = {
    name           = "ai-chat-pool"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    services = [
      { key = "ai_primary", source = "ai_backends", weight = 100, priority = 1 }
    ]
  }
}

api_management_policy_fragment = {
  ai_access_limits = {
    name           = "ai-access-limits"
    description    = "Per-product subscription quota and request-rate controls."
    api_management = { key = "ai_gateway" }
    value          = <<-XML
      <fragment>
        <rate-limit-by-key calls="60" renewal-period="60" counter-key="@(context.Subscription.Id)" />
        <quota-by-key calls="10000" renewal-period="86400" counter-key="@(context.Subscription.Id)" />
      </fragment>
    XML
  }
}

api_management_product = {
  ai_consumers = {
    product_id            = "ai-consumers"
    display_name          = "AI Consumers"
    published             = true
    subscription_required = true
    approval_required     = true
    subscriptions_limit   = 100
    api_management        = { key = "ai_gateway" }
    resource_group        = { key = "ai_gateway" }
  }
}

api_management_product_policy = {
  ai_consumers = {
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    product        = { key = "ai_consumers" }
    xml_content    = <<-XML
      <policies>
        <inbound><base /><include-fragment fragment-id="ai-access-limits" /></inbound>
        <backend><base /></backend>
        <outbound><base /></outbound>
        <on-error><base /></on-error>
      </policies>
    XML
  }
}

api_management_product_api = {
  ai_chat = {
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    product        = { key = "ai_consumers" }
    api            = { key = "ai_chat" }
  }
}

api_management_subscription = {
  ai_consumer = {
    display_name   = "AI Consumer"
    state          = "submitted"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    product        = { key = "ai_consumers" }
  }
}

api_management_api_policy = {
  ai_chat = {
    api            = { key = "ai_chat" }
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    xml_content    = <<-XML
      <policies>
        <inbound><base /><set-backend-service backend-id="ai-chat-pool" /></inbound>
        <backend><forward-request timeout="120" /></backend>
        <outbound><base /></outbound>
        <on-error><base /></on-error>
      </policies>
    XML
  }
}

api_center = {
  ai_catalog = {
    name = "ai-gateway-catalog"
    resource_group = {
      key = "ai_gateway"
    }
    identity = {
      type = "SystemAssigned"
    }
    workspaces = {
      default = {
        name  = "default"
        title = "Default"
        environments = {
          production = {
            name        = "production"
            title       = "Production"
            kind        = "production"
            description = "Production Azure API Management environment."
            server = {
              type                   = "Azure API Management"
              management_portal_uris = ["https://portal.azure.com"]
            }
          }
        }
        apis = {
          ai_chat = {
            name        = "ai-chat"
            title       = "AI Chat API"
            kind        = "rest"
            description = "Catalog registration for the APIM AI Gateway API."
            versions = {
              v01 = {
                name            = "v01"
                title           = "Version 1"
                lifecycle_stage = "production"
                definitions = {
                  openapi = {
                    name        = "openapi"
                    title       = "OpenAPI definition"
                    description = "Inline contract imported into API Center."
                    specification = {
                      format  = "inline"
                      name    = "openapi"
                      version = "3.0"
                      value   = <<-JSON
                        {
                          "openapi": "3.0.0",
                          "info": { "title": "AI Chat API", "version": "1.0" },
                          "paths": {
                            "/chat/completions": {
                              "post": {
                                "operationId": "createChatCompletion",
                                "responses": { "200": { "description": "Successful response" } }
                              }
                            }
                          }
                        }
                      JSON
                    }
                  }
                }
              }
            }
            deployments = {
              production = {
                name        = "production"
                title       = "Production APIM"
                description = "APIM deployment for the AI chat access contract."
                state       = "active"
                environment = { key = "production" }
                definition = {
                  version_key = "v01"
                  key         = "openapi"
                }
                server = {
                  runtime_uris = ["https://apim-ai-gateway.azure-api.net/ai/chat"]
                }
              }
            }
          }
        }
      }
    }
  }
}
