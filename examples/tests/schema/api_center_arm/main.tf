terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.13.0"
    }
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 3.1.0"
    }
  }
}

provider "azapi" {
  skip_provider_registration = true
}

module "api_center" {
  source = "../../../../modules/integration/api_center"

  global_settings = {
    default_region = "region1"
    regions        = { region1 = "westeurope" }
    passthrough    = true
    random_length  = 0
    use_slug       = false
  }
  client_config = {
    landingzone_key = "schema"
    subscription_id = "00000000-0000-0000-0000-000000000000"
  }
  settings = {
    name                = "schema-api-center"
    resource_group_name = "schema-rg"
    location            = "westeurope"
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
            onboarding = {
              instructions         = "Request access"
              developer_portal_uri = "https://developer.example.invalid"
            }
          }
        }
        apis = {
          chat = {
            name        = "ai-chat"
            title       = "AI Chat"
            kind        = "rest"
            description = "Schema validation fixture."
            contacts = [
              {
                name  = "Owner"
                email = "owner@example.invalid"
              }
            ]
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
                      format  = "inline"
                      name    = "openapi"
                      version = "3.0"
                      value   = "{\"openapi\":\"3.0.0\",\"info\":{\"title\":\"AI\",\"version\":\"1\"},\"paths\":{}}"
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
