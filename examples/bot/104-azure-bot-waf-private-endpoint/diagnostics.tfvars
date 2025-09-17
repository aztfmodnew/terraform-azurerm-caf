# Diagnostic Settings Configuration for Azure Bot with WAF
diagnostic_log_analytics = {
  central_logs_region1 = {
    region             = "region1"
    name               = "secure-bot-logs"
    resource_group_key = "monitoring_rg"

    # Log retention and settings
    solutions = {
      SecurityCenterFree = {
        publisher = "Microsoft"
        product   = "OMSGallery/SecurityCenterFree"
      }
      AzureWebAppsAnalytics = {
        publisher = "Microsoft"
        product   = "OMSGallery/AzureWebAppsAnalytics"
      }
      NetworkMonitoring = {
        publisher = "Microsoft"
        product   = "OMSGallery/NetworkMonitoring"
      }
    }

    tags = {
      purpose = "centralized-logging"
      service = "log-analytics"
    }
  }
}

# Diagnostic Settings for specific resources
diagnostics_definition = {
  application_gateway = {
    name = "operational_logs_and_metrics"

    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled", "Retention Enabled", "Retention_period"] 
        ["ApplicationGatewayAccessLog", true, false, 7],
        ["ApplicationGatewayPerformanceLog", true, false, 7],
        ["ApplicationGatewayFirewallLog", true, false, 30]
      ]

      metric = [
        #["Category name", "Diagnostics Enabled", "Retention Enabled", "Retention_period"]
        ["AllMetrics", true, false, 7]
      ]
    }
  }

  network_security_group = {
    name = "nsg_logs_and_metrics"

    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled", "Retention Enabled", "Retention_period"] 
        ["NetworkSecurityGroupEvent", true, false, 7],
        ["NetworkSecurityGroupRuleCounter", true, false, 7]
      ]

      metric = [
        #["Category name", "Diagnostics Enabled", "Retention Enabled", "Retention_period"]
        ["AllMetrics", true, false, 7]
      ]
    }
  }

  azurerm_key_vault = {
    name = "keyvault_logs_and_metrics"

    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled", "Retention Enabled", "Retention_period"] 
        ["AuditEvent", true, false, 30],
        ["AzurePolicyEvaluationDetails", true, false, 7]
      ]

      metric = [
        #["Category name", "Diagnostics Enabled", "Retention Enabled", "Retention_period"]
        ["AllMetrics", true, false, 7]
      ]
    }
  }

  azurerm_bot_channels_registration = {
    name = "bot_logs_and_metrics"

    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled", "Retention Enabled", "Retention_period"] 
        ["BotRequest", true, false, 30],
        ["DependencyRequest", true, false, 7]
      ]

      metric = [
        #["Category name", "Diagnostics Enabled", "Retention Enabled", "Retention_period"]
        ["AllMetrics", true, false, 7]
      ]
    }
  }

  private_endpoint = {
    name = "private_endpoint_logs"

    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled", "Retention Enabled", "Retention_period"] 
        ["PrivateEndpointNetworkPolicies", true, false, 7]
      ]

      metric = [
        #["Category name", "Diagnostics Enabled", "Retention Enabled", "Retention_period"]
        ["AllMetrics", true, false, 7]
      ]
    }
  }
}

# Diagnostic destinations
diagnostics_destinations = {
  log_analytics = {
    central_logs_region1 = {
      log_analytics_key              = "central_logs_region1"
      log_analytics_destination_type = "Dedicated"
    }
  }
}
