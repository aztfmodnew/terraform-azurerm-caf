# Advanced example: Hybrid Naming Comparison
# This example creates multiple AI Services with different naming methods
# to demonstrate how the hybrid naming system works

global_settings = {
  default_region = "region1"
  environment    = "demo"
  prefix         = "caf"
  suffix         = "001"
  
  regions = {
    region1 = "eastus"
    region2 = "westus"
  }
  
  # Enable azurecaf by default
  naming = {
    use_azurecaf      = true
    use_local_module  = false
    component_order   = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
  }
}

resource_groups = {
  naming_demo = {
    name = "naming-demo"
    location = "eastus"
  }
}

# Create multiple AI Services with different naming methods
ai_services = {

    # Service 1: Uses azurecaf naming (global default)
    azurecaf_service = {
      name               = "chatbot"
      sku_name          = "S0"
      resource_group_key = "naming_demo"
    }
    
    # Service 2: Uses local module naming (override global)
    local_module_service = {
      name               = "translator"
      sku_name          = "S0"
      resource_group_key = "naming_demo"
      
      # Override global naming for this resource
      use_local_module = true
      use_azurecaf     = false
    }
    
    # Service 3: Uses passthrough naming (exact name)
    passthrough_service = {
      name               = "my-exact-ai-service-name"
      sku_name          = "S0"
      resource_group_key = "naming_demo"
      
      # Override global naming for this resource
      passthrough = true
    }
    
    # Service 4: Uses custom component order
    custom_order_service = {
      name               = "analyzer"
      sku_name          = "S0"
      resource_group_key = "naming_demo"
      environment        = "prod"
      region             = "westus"
      instance           = "02"
      
      # Override global naming for this resource
      use_local_module = true
      use_azurecaf     = false
      component_order  = ["name", "environment", "region", "instance", "suffix"]
    }
  }
}

# Expected results:
# - azurecaf_service: caf-cog-chatbot-001 (azurecaf format)
# - local_module_service: caf-cog-translator-demo-eus-001 (local module format)
# - passthrough_service: my-exact-ai-service-name (exact name)
# - custom_order_service: analyzer-prod-wus-02-001 (custom order)
