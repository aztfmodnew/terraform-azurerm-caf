mock_provider "azapi" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "caf-api-center-resource" }
  }
}

run "stable_api_center_hierarchy" {
  command = plan
  module {
    source = "../modules/integration/api_center"
  }

  variables {
    global_settings = {
      passthrough    = true
      random_length  = 0
      use_slug       = true
      default_region = "region1"
      regions        = { region1 = "westeurope" }
    }
    client_config = {
      landingzone_key = "local"
      subscription_id = "00000000-0000-0000-0000-000000000000"
    }
    remote_objects = {
      resource_groups = {
        local = {
          catalog = {
            name     = "rg-api-center"
            location = "westeurope"
          }
        }
      }
    }
    settings = {
      name           = "ai-api-center"
      resource_group = { key = "catalog" }
      identity = {
        type = "SystemAssigned"
      }
      workspaces = {
        default = {
          name  = "default"
          title = "Default"
          environments = {
            production = {
              name  = "production"
              title = "Production"
              kind  = "production"
              server = {
                type                  = "Azure API Management"
                management_portal_uri = "https://portal.example.invalid"
              }
            }
          }
          apis = {
            chat = {
              name        = "ai-chat"
              title       = "AI Chat"
              kind        = "rest"
              description = "AI chat API"
              versions = {
                v01 = {
                  name            = "v01"
                  title           = "Version 1"
                  lifecycle_stage = "production"
                  definitions = {
                    openapi = {
                      name  = "openapi"
                      title = "OpenAPI"
                      specification = {
                        format = "inline"
                        value  = "{\"openapi\":\"3.0.0\",\"info\":{\"title\":\"AI Chat\",\"version\":\"1\"},\"paths\":{}}"
                      }
                    }
                  }
                }
              }
              deployments = {
                production = {
                  name        = "production"
                  title       = "Production"
                  state       = "active"
                  environment = { key = "production" }
                  definition = {
                    version_key = "v01"
                    key         = "openapi"
                  }
                  server = {
                    runtime_uris = ["https://gateway.example.invalid/ai"]
                  }
                }
              }
            }
          }
        }
      }
      metadata_schemas = {
        owner = {
          name   = "owner"
          schema = "{\"type\":\"object\",\"properties\":{\"owner\":{\"type\":\"string\"}}}"
          assigned_to = [
            { entity = "api", required = true }
          ]
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.service[0].type == "Microsoft.ApiCenter/services@2024-03-01"
    error_message = "The service must use the stable 2024-03-01 ARM contract and never AzureRM 5.14."
  }
  assert {
    condition     = azapi_resource.service[0].body.identity.type == "SystemAssigned"
    error_message = "System-assigned managed identity must be emitted at the service top level."
  }
  assert {
    condition     = azapi_resource.environments["default/production"].body.properties.kind == "production"
    error_message = "The default workspace must contain the declared production environment."
  }
  assert {
    condition     = azapi_resource.api_versions["default/chat/v01"].body.properties.lifecycleStage == "production"
    error_message = "The API version must carry the writable lifecycle stage."
  }
  assert {
    condition     = azapi_resource_action.import_specification["default/chat/v01/openapi"].action == "importSpecification"
    error_message = "A definition specification must be imported after the definition resource is created."
  }
  assert {
    condition     = azapi_resource.deployments["default/chat/production"].body.properties.state == "active"
    error_message = "Deployment state must be included in the stable writable body."
  }
  assert {
    condition     = azapi_resource.metadata_schemas["owner"].body.properties.assignedTo[0].entity == "api"
    error_message = "Optional metadata schemas must support API assignments."
  }
}

run "existing_remote_service_supports_child_registration" {
  command = plan
  module {
    source = "../modules/integration/api_center"
  }

  variables {
    global_settings = { passthrough = true, random_length = 0 }
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_centers = {
        shared = {
          catalog = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/shared/providers/Microsoft.ApiCenter/services/shared" }
        }
      }
    }
    settings = {
      service = {
        key    = "catalog"
        lz_key = "shared"
      }
      workspaces = {
        default = {
          name  = "default"
          title = "Default"
        }
      }
    }
  }

  assert {
    condition     = length(azapi_resource.service) == 0 && azapi_resource.workspaces["default"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/shared/providers/Microsoft.ApiCenter/services/shared"
    error_message = "A remote API Center ID must be usable as the parent without recreating the service."
  }
}

run "preview_api_version_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/integration/api_center"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name        = "api-center"
      api_version = "2024-06-01-preview"
    }
  }
}
