terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
    azurecaf = {
      source = "aztfmodnew/azurecaf"
    }
  }
}

resource "azapi_resource" "upstream_service" {
  type      = "Microsoft.ApiCenter/services@2024-03-01"
  name      = "upstream-service"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/computed"
  location  = "westeurope"

  body = {
    properties = {}
  }
}

module "catalog" {
  source = "../../../../../../modules/integration/api_center"

  global_settings = {
    passthrough   = true
    random_length = 0
  }
  client_config = {
    landingzone_key = "computed"
  }
  settings = {
    create_service = false
    service_id     = azapi_resource.upstream_service.id
    workspaces = {
      default = {
        name  = "default"
        title = "Default"
      }
    }
  }
}

output "workspace_count" {
  value = length(module.catalog.workspaces)
}
