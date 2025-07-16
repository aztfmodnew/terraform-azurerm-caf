# Basic example: azurecaf naming (default method)
# This is the current production method used in the CAF framework

global_settings = {
  default_region = "region1"
  environment    = "test"
  prefix         = "caf"
  suffix         = "001"
  
  regions = {
    region1 = "eastus"
  }
  
  # Default naming configuration (azurecaf)
  naming = {
    use_azurecaf      = true
    use_local_module  = false
  }
}

resource_groups = {
  test = {
    name = "test-rg"
    location = "eastus"
  }
}

ai_services = {
  simple_service = {
    name               = "chatbot"
    sku_name          = "S0"
    resource_group_key = "test"
  }
}

# Expected result: caf-cog-chatbot-001 (azurecaf format)
