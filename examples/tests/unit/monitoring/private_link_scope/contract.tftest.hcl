mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults = {
      result = "private-monitoring"
    }
  }
}

variables {
  global_settings = {
    prefixes      = []
    suffixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
    regions       = { region1 = "westeurope" }
    tags          = { environment = "test" }
  }
  client_config = {
    landingzone_key = "local"
  }
  remote_objects = {
    resource_groups = {
      local = {
        monitoring = {
          name     = "monitoring"
          location = "westeurope"
          tags     = { cost_center = "observability" }
        }
      }
    }
    log_analytics = {
      local = {
        workspace = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring/providers/Microsoft.OperationalInsights/workspaces/workspace"
        }
      }
    }
    application_insights = {
      local = {
        component = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring/providers/Microsoft.Insights/components/component"
        }
      }
    }
    vnets = {
      local = {
        monitoring = {
          subnets = {
            private_endpoints = {
              id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring/providers/Microsoft.Network/virtualNetworks/monitoring/subnets/private-endpoints"
            }
          }
        }
      }
    }
    private_dns = {
      local = {
        monitor = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring/providers/Microsoft.Network/privateDnsZones/privatelink.monitor.azure.com"
        }
      }
    }
  }
}

run "passes_complete_ampls_contract" {
  command = plan

  module {
    source = "../modules/monitoring/private_link_scope"
  }

  variables {
    base_tags = true
    settings = {
      name                  = "ampls"
      resource_group_key    = "monitoring"
      ingestion_access_mode = "PrivateOnly"
      query_access_mode     = "PrivateOnly"
      tags                  = { owner = "platform" }
      scoped_services = {
        workspace = {
          name = "workspace"
          log_analytics = {
            key = "workspace"
          }
          timeouts = {
            create = "45m"
            read   = "6m"
            delete = "45m"
          }
        }
        component = {
          name = "component"
          application_insights = {
            key = "component"
          }
        }
      }
      timeouts = {
        create = "45m"
        read   = "6m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_monitor_private_link_scope.scope.ingestion_access_mode == "PrivateOnly" &&
      azurerm_monitor_private_link_scope.scope.query_access_mode == "PrivateOnly" &&
      azurerm_monitor_private_link_scope.scope.tags.environment == "test" &&
      azurerm_monitor_private_link_scope.scope.tags.cost_center == "observability" &&
      azurerm_monitor_private_link_scope.scope.tags.owner == "platform" &&
      azurerm_monitor_private_link_scope.scope.timeouts.create == "45m" &&
      azurerm_monitor_private_link_scope.scope.timeouts.update == "45m" &&
      azurerm_monitor_private_link_scoped_service.scoped_service["workspace"].linked_resource_id == var.remote_objects.log_analytics.local.workspace.id &&
      azurerm_monitor_private_link_scoped_service.scoped_service["component"].linked_resource_id == var.remote_objects.application_insights.local.component.id &&
      azurerm_monitor_private_link_scoped_service.scoped_service["workspace"].timeouts.delete == "45m"
    )
    error_message = "AMPLS arguments, references, inherited tags, and timeouts must reach both provider resources."
  }
}

run "preserves_azure_5_14_defaults" {
  command = plan

  module {
    source = "../modules/monitoring/private_link_scope"
  }

  variables {
    base_tags = false
    settings = {
      name               = "defaults"
      resource_group_key = "monitoring"
      scoped_services = {
        direct = {
          name               = "direct"
          linked_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/monitoring/providers/Microsoft.Insights/components/direct"
        }
      }

    }
  }

  assert {
    condition = (
      azurerm_monitor_private_link_scope.scope.ingestion_access_mode == "Open" &&
      azurerm_monitor_private_link_scope.scope.query_access_mode == "Open" &&
      azurerm_monitor_private_link_scoped_service.scoped_service["direct"].name == "private-monitoring"
    )
    error_message = "Omitted AMPLS access modes must retain AzureRM 5.14 Open defaults and CAF naming must apply."
  }
}

run "forces_the_ampls_private_endpoint_contract" {
  command = plan

  module {
    source = "../modules/monitoring/private_link_scope"
  }

  variables {
    base_tags = false
    settings = {
      name               = "private"
      resource_group_key = "monitoring"
      private_endpoints = {
        monitor = {
          name       = "ampls"
          vnet_key   = "monitoring"
          subnet_key = "private_endpoints"
          private_service_connection = {
            name                 = "ampls"
            is_manual_connection = false
            subresource_names    = ["incorrect"]
          }
          private_dns = {
            zone_group_name = "azure-monitor"
            keys            = ["monitor"]
          }
        }
      }
    }
  }

  assert {
    condition = (
      output.private_endpoints["monitor"].private_service_connection[0].subresource_names[0] == "azuremonitor" &&
      length(output.private_endpoints["monitor"].private_dns_zone_group[0].private_dns_zone_ids) == 1 &&
      output.private_endpoints["monitor"].private_dns_zone_group[0].private_dns_zone_ids[0] == var.remote_objects.private_dns.local.monitor.id
    )
    error_message = "AMPLS private endpoints must use azuremonitor and preserve DNS zone-group references."
  }
}
