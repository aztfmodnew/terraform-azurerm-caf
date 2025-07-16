# Example 202: Local naming module with validation
# This example demonstrates using the local naming module with validation features
# Result will be something like: contoso-cog-chatbot-prod-eus-001

global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "contoso"
  suffix         = "001"
  
  regions = {
    region1 = "eastus"
    region2 = "westus"
  }
  
  naming = {
    use_azurecaf      = false
    use_local_module  = true
    component_order   = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
  }
}

resource_groups = {
  main = {
    name     = "main-rg"
    location = "eastus"
  }
}

ai_services = {

    valid_service = {
      name               = "chatbot"
      sku_name          = "S0"
      resource_group_key = "main"
      
      # Override global settings for this resource
      environment = "prod"
      region      = "eastus"
      instance    = "001"
    }
    
    custom_order_service = {
      name               = "translator"
      sku_name          = "S1"
      resource_group_key = "main"
      
      # Different environment and region
      environment = "test"
      region      = "westus"
      instance    = "002"
    }
    
    # This will test validation - uncomment to see validation errors
    # invalid_service = {
    #   name               = "this-name-is-way-too-long-for-cognitive-services-and-should-fail-validation"
    #   sku_name          = "S0"
    #   resource_group_key = "main"
    # }
  }
}
