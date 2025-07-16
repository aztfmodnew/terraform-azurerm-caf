# Basic example: passthrough naming (exact names)
# Use exact names without any transformation

global_settings = {
  default_region = "region1"
  environment    = "test"
  passthrough    = true  # Use exact names
  
  regions = {
    region1 = "eastus"
  }
}

resource_groups = {
  test = {
    name = "test-rg"
    location = "eastus"
  }
}

ai_services = {
  exact_name_service = {
    name               = "my-exact-ai-service-name"
    sku_name          = "S0"
    resource_group_key = "test"
  }
}

# Expected result: my-exact-ai-service-name (exact name)
