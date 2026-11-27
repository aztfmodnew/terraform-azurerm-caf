global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  inherit_tags  = true
  random_length = 5
  tags = {
    scenario = "private-monitoring"
  }
}

resource_groups = {
  monitoring = {
    name = "private-monitoring"
    tags = {
      workload = "observability"
    }
  }
}

log_analytics = {
  gateway = {
    name               = "gateway-observability"
    resource_group_key = "monitoring"
    retention_in_days  = 30
  }
}

azurerm_application_insights = {
  gateway = {
    name               = "gateway-insights"
    resource_group_key = "monitoring"
    application_type   = "web"
    log_analytics_workspace = {
      key = "gateway"
    }
  }
}

vnets = {
  monitoring = {
    resource_group_key = "monitoring"
    vnet = {
      name          = "monitoring"
      address_space = ["10.60.0.0/16"]
    }
    subnets = {
      private_endpoints = {
        name                              = "private-endpoints"
        cidr                              = ["10.60.1.0/24"]
        private_endpoint_network_policies = "Enabled"
      }
    }
  }
}

private_dns = {
  monitor = {
    name               = "privatelink.monitor.azure.com"
    resource_group_key = "monitoring"
    vnet_links = {
      monitoring = {
        name     = "monitor"
        vnet_key = "monitoring"
      }
    }
  }
  oms = {
    name               = "privatelink.oms.opinsights.azure.com"
    resource_group_key = "monitoring"
    vnet_links = {
      monitoring = {
        name     = "oms"
        vnet_key = "monitoring"
      }
    }
  }
  ods = {
    name               = "privatelink.ods.opinsights.azure.com"
    resource_group_key = "monitoring"
    vnet_links = {
      monitoring = {
        name     = "ods"
        vnet_key = "monitoring"
      }
    }
  }
  agentsvc = {
    name               = "privatelink.agentsvc.azure-automation.net"
    resource_group_key = "monitoring"
    vnet_links = {
      monitoring = {
        name     = "agentsvc"
        vnet_key = "monitoring"
      }
    }
  }
  blob = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "monitoring"
    vnet_links = {
      monitoring = {
        name     = "blob"
        vnet_key = "monitoring"
      }
    }
  }
}

monitor_private_link_scopes = {
  gateway = {
    name                  = "gateway-ampls"
    resource_group_key    = "monitoring"
    ingestion_access_mode = "PrivateOnly"
    query_access_mode     = "PrivateOnly"

    scoped_services = {
      log_analytics = {
        name = "gateway-log-analytics"
        log_analytics = {
          key = "gateway"
        }
        timeouts = {
          create = "45m"
          read   = "6m"
          delete = "45m"
        }
      }
      application_insights = {
        name = "gateway-application-insights"
        application_insights = {
          key = "gateway"
        }
      }
    }

    private_endpoints = {
      azure_monitor = {
        name       = "gateway-ampls"
        vnet_key   = "monitoring"
        subnet_key = "private_endpoints"
        private_service_connection = {
          name                 = "gateway-ampls"
          is_manual_connection = false
          subresource_names    = ["azuremonitor"]
        }
        private_dns = {
          zone_group_name = "azure-monitor"
          keys = [
            "monitor",
            "oms",
            "ods",
            "agentsvc",
            "blob"
          ]
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
