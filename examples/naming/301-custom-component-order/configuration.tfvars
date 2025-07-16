# Advanced example: custom component order
# Demonstrates flexible component ordering with the local naming module

global_settings = {
  default_region = "region1"
  environment    = "production"   # Will be converted to "prod"
  prefix         = "acme"
  suffix         = "v1"
  
  regions = {
    region1 = "eastus"    # Will be converted to "eus"
    region2 = "westus"    # Will be converted to "wus"
  }
  
  # Global custom component order
  naming = {
    use_azurecaf      = false
    use_local_module  = true
    component_order   = ["name", "abbreviation", "environment", "region", "instance", "prefix", "suffix"]
  }
}

resource_groups = {
  prod = {
    name = "prod-rg"
    location = "eastus"
  }
}

ai_services = {

    # Service with global custom order
    global_custom_service = {
      name               = "chatbot"
      sku_name          = "S0"
      resource_group_key = "prod"
      instance           = "01"
    }
    
    # Service with resource-specific custom order
    resource_custom_service = {
      name               = "analyzer"
      sku_name          = "S0"
      resource_group_key = "prod"
      environment        = "staging"    # Will be converted to "stg"
      region             = "westus"     # Will be converted to "wus"
      instance           = "02"
      
      # Override component order for this resource
      component_order = ["prefix", "name", "environment", "region", "instance", "suffix"]
    }
    
    # Service with minimal components
    minimal_service = {
      name               = "simple"
      sku_name          = "S0"
      resource_group_key = "prod"
      
      # Only use essential components
      component_order = ["name", "abbreviation", "environment"]
    }
}

# Expected results with automatic conversions:
# - global_custom_service: chatbot-ai-prod-eus-01-acme-v1
# - resource_custom_service: acme-analyzer-stg-wus-02-v1 
# - minimal_service: simple-ai-prod
