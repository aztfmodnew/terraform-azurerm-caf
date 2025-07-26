# Intermediate example: local module naming
# Use the local naming module for CAF-compliant names with validation

global_settings = {
  default_region = "region1"
  environment    = "staging"
  prefix         = "contoso"
  suffix         = "001"

  regions = {
    region1 = "eastus"
    region2 = "westus"
  }

  # Use local naming module
  naming = {
    use_azurecaf     = false
    use_local_module = true
    component_order  = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
  }
}

resource_groups = {
  staging = {
    name     = "staging-rg"
    location = "eastus"
  }
}

ai_services = {
  main_service = {
    name               = "chatbot"
    sku_name           = "S0"
    resource_group_key = "staging"
  }

  regional_service = {
    name               = "translator"
    sku_name           = "S0"
    resource_group_key = "staging"
    region             = "westus" # Override region
    instance           = "02"     # Add instance number
  }
}

# Expected results:
# - main_service: contoso-cog-chatbot-staging-eus-001
# - regional_service: contoso-cog-translator-staging-wus-02-001
