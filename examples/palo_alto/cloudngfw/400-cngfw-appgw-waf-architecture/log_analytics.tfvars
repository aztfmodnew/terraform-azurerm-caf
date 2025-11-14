# Centralized Log Analytics workspace for Application Gateway and WAF diagnostics

# Workspaces deployed through the diagnostics block so diagnostic profiles can reference them directly
# via destination keys. The workspace lives in the networking resource group to keep logging close to
# the data plane resources.
diagnostic_log_analytics = {
  central_logs_region1 = {
    region             = "region1"
    name               = "central-logs"
    resource_group_key = "networking_rg"
    sku                = "PerGB2018"
    retention_in_days  = 90
    daily_quota_gb     = 10

    solutions_maps = {
      NetworkMonitoring = {
        publisher = "Microsoft"
        product   = "OMSGallery/NetworkMonitoring"
      }
      SecurityInsights = {
        publisher = "Microsoft"
        product   = "OMSGallery/SecurityInsights"
      }
    }

    tags = {
      environment = "production"
      purpose     = "central-logging"
    }
  }
}

# Diagnostic categories enabled for key services (starting with Application Gateway WAF)
diagnostics_definition = {
  application_gateway = {
    name = "appgw-logs-and-metrics"
    categories = {
      log = [
        ["ApplicationGatewayAccessLog", true, false, 30],
        ["ApplicationGatewayPerformanceLog", true, false, 30],
        ["ApplicationGatewayFirewallLog", true, false, 90]
      ]
      metric = [
        ["AllMetrics", true, false, 30]
      ]
    }
  }
}

# Route diagnostic profiles to the centralized workspace via the destination key referenced in
# application_gateway.tfvars (destination_key = "central_logs").
diagnostics_destinations = {
  log_analytics = {
    central_logs = {
      log_analytics_key              = "central_logs_region1"
      log_analytics_destination_type = "Dedicated"
    }
  }
}
