override_resource {
  target          = azurecaf_name.resource
  override_during = plan
  values          = { result = "ai-east" }
}

run "direct_https_endpoint_uses_system_identity_policy" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = { passthrough = true, random_length = 0, use_slug = false }
    client_config   = { landingzone_key = "local", subscription_id = "00000000-0000-0000-0000-000000000000" }
    base_tags       = {}
    remote_objects = {
      managed_identities = {
        local = {
          unrelated = {
            name      = "unrelated"
            client_id = "22222222-2222-2222-2222-222222222222"
          }
        }
      }
    }
    settings = {
      name              = "ai-east"
      endpoint          = "https://ai-east.example.invalid"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      tls = {
        validate_certificate_chain = true
        validate_certificate_name  = false
      }
      reconnect = {
        enabled = true
        after   = "PT2M"
      }
      timeouts = { create = "30m" }
    }
  }
  assert {
    condition     = azapi_resource.resource.body.properties.type == "Single" && azapi_resource.resource.body.properties.url == "https://ai-east.example.invalid/"
    error_message = "The AI backend must emit the single ARM backend contract and normalize the HTTPS endpoint."
  }
  assert {
    condition     = strcontains(output.authentication_policy, "authentication-managed-identity") && !strcontains(output.authentication_policy, "client-id")
    error_message = "Omitting an identity selector must use the APIM system-assigned identity and not match unrelated remote identities."
  }
  assert {
    condition     = azapi_resource.resource.body.properties.tls.validateCertificateChain == true && azapi_resource.resource.body.properties.tls.validateCertificateName == false
    error_message = "TLS settings must be mapped to the ARM camelCase property names."
  }
  assert {
    condition     = azapi_resource_action.reconnect[0].action == "reconnect"
    error_message = "The reconnect action must be selectable."
  }
}

run "managed_identity_client_id_is_resolved_by_key" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local", subscription_id = "00000000-0000-0000-0000-000000000000" }
    remote_objects = {
      managed_identities = {
        local = {
          apim = {
            name      = "id-apim"
            client_id = "11111111-1111-1111-1111-111111111111"
          }
        }
      }
    }
    settings = {
      name              = "ai-east"
      endpoint          = "https://ai-east.example.invalid"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      managed_identity  = { key = "apim" }
    }
  }
  assert {
    condition     = output.managed_identity_name == "id-apim" && strcontains(output.authentication_policy, "11111111-1111-1111-1111-111111111111")
    error_message = "A managed identity key must resolve its client ID and name."
  }
}

run "http_endpoint_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-east"
      endpoint          = "http://ai-east.example.invalid"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
    }
  }
}

run "direct_url_alias_is_normalized" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-url"
      url               = "https://ai-url.example.invalid/"
      endpoint_path     = "/openai"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
    }
  }
  assert {
    condition     = output.url == "https://ai-url.example.invalid/openai" && output.endpoint == "https://ai-url.example.invalid/"
    error_message = "The direct url alias must be normalized without duplicate slashes."
  }
  assert {
    condition     = azapi_resource.resource.name == "ai-east"
    error_message = "CAF naming must feed the APIM backend child name."
  }
}

run "ai_services_remote_key_resolves_endpoint" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      ai_services = {
        remote = {
          foundry = { endpoint = "https://foundry.example.invalid" }
        }
      }
    }
    settings = {
      name              = "ai-remote"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      ai_services       = { key = "foundry", lz_key = "remote" }
      endpoint_path     = "models/chat"
    }
  }
  assert {
    condition     = output.endpoint == "https://foundry.example.invalid" && output.url == "https://foundry.example.invalid/models/chat"
    error_message = "AI Services keys must resolve from the selected landing zone and preserve endpoint paths."
  }
}

run "cognitive_account_endpoint_reference_is_supported" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name                       = "ai-account"
      api_management_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      cognitive_services_account = { endpoint = "https://account.example.invalid/" }
    }
  }
  assert {
    condition     = output.endpoint == "https://account.example.invalid/"
    error_message = "Cognitive account references must support an explicit HTTPS endpoint."
  }
}

run "deployment_reference_resolves_parent_account_endpoint" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      cognitive_deployment = {
        local = {
          chat = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.CognitiveServices/accounts/oai/deployments/chat"
          }
        }
      }
      cognitive_services_accounts = {
        local = {
          account = {
            id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.CognitiveServices/accounts/oai"
            endpoint = "https://gateway-oai.cognitiveservices.azure.com/"
          }
        }
      }
    }
    settings = {
      name                 = "ai-deployment"
      api_management_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      cognitive_deployment = { key = "chat" }
    }
  }
  assert {
    condition     = output.endpoint == "https://gateway-oai.cognitiveservices.azure.com/"
    error_message = "A deployment must use its resolved parent account endpoint rather than synthesizing a public OpenAI host from the ARM resource name."
  }
}

run "unresolved_managed_identity_selector_is_rejected" {
  command         = plan
  expect_failures = [azapi_resource.resource]
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-identity"
      endpoint          = "https://ai-identity.example.invalid"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      managed_identity  = { key = "misspelled" }
    }
  }
}

run "project_reference_selects_named_endpoint" {
  command = plan
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      cognitive_account_project = {
        local = {
          foundry = {
            endpoints = {
              project = "https://project.example.invalid"
              models  = "https://models.example.invalid"
            }
          }
        }
      }
    }
    settings = {
      name                      = "ai-project"
      api_management_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      cognitive_account_project = { key = "foundry", endpoint_key = "models" }
    }
  }
  assert {
    condition     = output.endpoint == "https://models.example.invalid"
    error_message = "A Foundry project key and endpoint_key must select the requested endpoint."
  }
}

run "multiple_endpoint_sources_are_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_ai_backend"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-conflict"
      endpoint          = "https://ai-direct.example.invalid"
      url               = "https://ai-url.example.invalid"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
    }
  }
}
