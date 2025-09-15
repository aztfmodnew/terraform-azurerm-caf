# Resource Groups Configuration for Azure Bot with WAF and Private Endpoint
resource_groups = {
  # Main resource group for bot services
  bot_rg = {
    name     = "azure-bot-waf-pe-rg"
    location = "westeurope"

    tags = {
      purpose     = "azure-bot-services"
      environment = "production"
      cost_center = "it-security"
    }
  },

  # Networking resource group for network infrastructure
  networking_rg = {
    name     = "azure-bot-networking-rg"
    location = "westeurope"

    tags = {
      purpose     = "networking-infrastructure"
      environment = "production"
      cost_center = "it-security"
    }
  },

  # Monitoring resource group for observability resources
  monitoring_rg = {
    name     = "azure-bot-monitoring-rg"
    location = "westeurope"

    tags = {
      purpose     = "monitoring-observability"
      environment = "production"
      cost_center = "it-security"
    }
  }
}
