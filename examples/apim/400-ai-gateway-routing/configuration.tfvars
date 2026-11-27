global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 0
  passthrough    = true
  use_slug       = false
}

resource_groups = {
  ai_gateway = {
    name = "rg-ai-gateway-routing"
  }
}

api_management = {
  ai_gateway = {
    name            = "apim-ai-gateway-routing"
    region          = "region1"
    publisher_name  = "AI Gateway"
    publisher_email = "owner@example.invalid"
    sku_name        = "Developer_1"
    resource_group  = { key = "ai_gateway" }
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["ai_gateway"]
    }
  }
}

api_management_api = {
  ai_gateway = {
    name           = "ai-gateway"
    display_name   = "AI Gateway"
    revision       = "1"
    path           = "ai"
    protocols      = ["https"]
    service_url    = "https://example.invalid"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
  }
}

api_management_api_operation = {
  chat_completions = {
    operation_id   = "chat-completions"
    display_name   = "Chat completions"
    method         = "POST"
    url_template   = "/openai/deployments/{deployment}/chat/completions"
    description    = "Routes an Azure OpenAI chat-completions request through the backend pool."
    api            = { key = "ai_gateway" }
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    template_parameters = {
      deployment = {
        name        = "deployment"
        required    = true
        type        = "string"
        description = "Azure OpenAI deployment name."
      }
    }
  }
}

managed_identities = {
  ai_gateway = {
    name               = "id-ai-gateway-routing"
    resource_group_key = "ai_gateway"
  }
}

api_management_ai_backend = {
  east = {
    name           = "ai-east"
    endpoint       = "https://ai-east.example.invalid"
    endpoint_path  = ""
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    managed_identity = {
      key = "ai_gateway"
    }
    description = "Primary AI backend; replace symbolic hostname for a real deployment."
  }
  west = {
    name           = "ai-west"
    endpoint       = "https://ai-west.example.invalid"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    managed_identity = {
      key = "ai_gateway"
    }
    description = "Secondary AI backend; endpoint is safe to mock in contract validation."
  }
}

api_management_backend_pool = {
  ai = {
    name        = "ai-pool"
    api_version = "2025-09-01-preview"
    api_management = {
      key = "ai_gateway"
    }
    resource_group = {
      key = "ai_gateway"
    }
    services = [
      { key = "east", source = "ai_backends", weight = 70, priority = 1 },
      { key = "west", source = "ai_backends", weight = 30, priority = 1 }
    ]
    session_affinity = {
      cookie_name = "ai-gateway-session"
    }
    failure_response_status_code = 503
  }
}

api_management_named_value = {
  jwt_issuer = {
    name           = "jwt-issuer"
    display_name   = "jwt-issuer"
    value          = "https://login.microsoftonline.com/common/v2.0"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
  }
  jwt_audience = {
    name           = "jwt-audience"
    display_name   = "jwt-audience"
    value          = "00000000-0000-0000-0000-000000000000"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
  }
  request_limit = {
    name           = "ai-request-limit"
    display_name   = "ai-request-limit"
    value          = "60"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
  }
  managed_identity_client_id = {
    name           = "ai-identity-client-id"
    display_name   = "ai-identity-client-id"
    value          = "00000000-0000-0000-0000-000000000001"
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
  }
}

api_management_policy_fragment = {
  ai_auth = {
    name           = "ai-routing-auth"
    description    = "Managed identity authentication and request-rate controls."
    api_management = { key = "ai_gateway" }
    value          = <<-XML
      <fragment>
        <authentication-managed-identity resource="https://cognitiveservices.azure.com" client-id="{{ai-identity-client-id}}" />
        <rate-limit-by-key calls="{{ai-request-limit}}" renewal-period="60" counter-key="@(context.Subscription?.Id ?? context.Request.IpAddress)" />
      </fragment>
    XML
  }
}

api_management_api_policy = {
  ai_routing = {
    api            = { key = "ai_gateway" }
    api_management = { key = "ai_gateway" }
    resource_group = { key = "ai_gateway" }
    xml_content    = <<-XML
      <policies>
        <inbound>
          <base />
          <validate-jwt header-name="Authorization" require-scheme="Bearer">
            <openid-config url="{{jwt-issuer}}/.well-known/openid-configuration" />
            <audiences><audience>{{jwt-audience}}</audience></audiences>
          </validate-jwt>
          <include-fragment fragment-id="ai-routing-auth" />
          <set-backend-service backend-id="ai-pool" />
          <set-variable name="route" value="pool" />
        </inbound>
        <backend><forward-request timeout="120" /></backend>
        <outbound>
          <base />
          <trace source="ai-gateway" severity="information">
            <message>@(JsonConvert.SerializeObject(new { @event = "ai-complete", route = context.Variables.GetValueOrDefault&lt;string&gt;("route", "unknown"), status = context.Response.StatusCode, latencyMs = Convert.ToInt64(context.Elapsed.TotalMilliseconds), correlation = context.Request.Headers.GetValueOrDefault("x-correlation-id", "") }))</message>
          </trace>
        </outbound>
        <on-error>
          <base />
          <trace source="ai-gateway" severity="error">
            <message>@(JsonConvert.SerializeObject(new { @event = "ai-error", route = context.Variables.GetValueOrDefault&lt;string&gt;("route", "unknown"), status = context.Response?.StatusCode ?? 0, latencyMs = Convert.ToInt64(context.Elapsed.TotalMilliseconds), correlation = context.Request.Headers.GetValueOrDefault("x-correlation-id", "") }))</message>
          </trace>
        </on-error>
      </policies>
    XML
  }
}
