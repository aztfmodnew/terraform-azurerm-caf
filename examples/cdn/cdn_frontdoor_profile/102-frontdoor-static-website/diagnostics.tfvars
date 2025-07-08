# Diagnostic logs definition for Front Door
diagnostics_definition = {
  cdn_frontdoor_profile = {
    name = "frontdoor_operational_logs"
    categories = {
      log = [
        # [Category, Enabled]
        ["FrontDoorAccessLog", true],
        ["FrontDoorHealthProbeLog", true],
        ["FrontDoorWebApplicationFirewallLog", true],
      ]
      metric = [
        # [Category, Enabled]
        ["AllMetrics", true],
      ]
    }
  }
}

# Destinations for diagnostic logs
diagnostics_destinations = {
  log_analytics = {
    central_logs = {
      log_analytics_key = "central_logs"
    }
  }
  storage = {
    all_regions = {
      eastus = {
        storage_account_key = "diagnostic_logs"
      }
      westus2 = {
        storage_account_key = "diagnostic_logs"
      }
    }
  }
}

# Log Analytics Workspace to centralize logs
log_analytics = {
  central_logs = {
    name               = "law-frontdoor-logs"
    resource_group_key = "static_website"
    retention_in_days  = 30
    sku                = "PerGB2018"
    
    tags = {
      purpose = "centralized logging"
    }
  }
}

# Additional Storage Account for diagnostic logs (optional)
diagnostic_storage_accounts = {
  diagnostic_logs = {
    name                     = "stdiagnosticlogs"
    resource_group_key       = "static_website"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind            = "StorageV2"
    
    # Configuration for log retention
    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      delete_retention_policy  = {
        days = 30
      }
      container_delete_retention_policy = {
        days = 30
      }
    }

    # Configure lifecycle management for diagnostic logs retention
    management_policy = [
      {
        name    = "diagnostic_logs_lifecycle"
        enabled = true
        
        filter = {
          prefix_match = ["frontdoor/"]
        }
        
        rule = {
          # Delete diagnostic logs after 90 days to control costs
          delete_after_days_since_modification_greater_than = 90
          
          # Move to cool tier after 7 days for cost optimization
          tier_to_cool_after_days_since_modification_greater_than = 7
          
          # Move to archive tier after 30 days for long-term retention
          tier_to_archive_after_days_since_modification_greater_than = 30
        }
      },
      {
        name    = "general_logs_lifecycle"
        enabled = true
        
        filter = {
          prefix_match = ["logs/"]
        }
        
        rule = {
          # Keep general logs for 365 days for compliance
          delete_after_days_since_modification_greater_than = 365
          
          # Move to cool tier after 30 days
          tier_to_cool_after_days_since_modification_greater_than = 30
          
          # Move to archive tier after 90 days
          tier_to_archive_after_days_since_modification_greater_than = 90
        }
      }
    ]
    
    # Allow access from Azure services
    network_rules = {
      default_action = "Allow"
      bypass         = ["AzureServices"]
    }

    tags = {
      purpose = "diagnostic logs storage"
    }
  }
}
