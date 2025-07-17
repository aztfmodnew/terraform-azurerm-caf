# Example 103: Azurecaf naming with random suffix
# This example demonstrates using azurecaf with random string generation for unique naming
# Result will be something like: contoso-cog-chatbot-4x7a

global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "contoso"
  random_length  = 4
  random_seed    = "chatbot"
  
  regions = {
    region1 = "eastus"
    region2 = "westus"
  }
  
  naming = {
    use_azurecaf      = true
    use_local_module  = false
  }
}

resource_groups = {
  main = {
    name     = "main-rg"
    location = "eastus"
  }
}

ai_services = {
  chatbot = {
    name               = "chatbot"
    sku_name          = "S0"
    resource_group_key = "main"
    
    # Optional configuration
    public_network_access = "Enabled"
    local_authentication_enabled = true
  }
  
  translator = {
    name               = "translator"
    sku_name          = "S1"
    resource_group_key = "main"
    
    # Different random seed for different name
    custom_subdomain_name = "translator-api"
  }
}
