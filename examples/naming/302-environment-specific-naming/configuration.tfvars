# Example 302: Environment-specific naming patterns
# This example demonstrates different naming strategies per environment
# Dev: Short names, no region, passthrough for testing
# Staging: Local module with custom order
# Production: Azurecaf with random for uniqueness

variable "environment" {
  description = "Environment to deploy to"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

locals {
  # Environment-specific naming configuration
  environment_configs = {
    dev = {
      use_passthrough = true
      prefix         = "dev"
      suffix         = ""
      random_length  = 0
      naming = {
        use_azurecaf      = false
        use_local_module  = false
      }
    }
    
    staging = {
      use_passthrough = false
      prefix         = "stg"
      suffix         = "001"
      random_length  = 0
      naming = {
        use_azurecaf      = false
        use_local_module  = true
        component_order   = ["prefix", "abbreviation", "name", "environment"]
      }
    }
    
    prod = {
      use_passthrough = false
      prefix         = "prod"
      suffix         = ""
      random_length  = 4
      naming = {
        use_azurecaf      = true
        use_local_module  = false
      }
    }
  }
  
  current_config = local.environment_configs[var.environment]
}

global_settings = merge({
  default_region = "region1"
  environment    = var.environment
  prefix         = local.current_config.prefix
  suffix         = local.current_config.suffix
  random_length  = local.current_config.random_length
  passthrough    = local.current_config.use_passthrough
  
  regions = {
    region1 = "eastus"
    region2 = "westus"
  }
}, {
  naming = local.current_config.naming
})

resource_groups = {
  main = {
    name     = "main-rg"
    location = "eastus"
  }
}

ai_services = {

    chatbot = {
      name               = var.environment == "dev" ? "my-dev-chatbot" : "chatbot"
      sku_name          = var.environment == "prod" ? "S1" : "S0"
      resource_group_key = "main"
      
      # Environment-specific configuration
      public_network_access = var.environment == "prod" ? "Disabled" : "Enabled"
      local_authentication_enabled = var.environment != "prod"
    }
    
    translator = {
      name               = var.environment == "dev" ? "my-dev-translator" : "translator"
      sku_name          = "S0"
      resource_group_key = "main"
      
      # Only deploy in staging and prod
      count = var.environment == "dev" ? 0 : 1
    }
  }
}
