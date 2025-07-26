# Advanced example: custom component order
# Demonstrates flexible component ordering with the hybrid naming system

global_settings = {
  default_region = "region1"
  environment    = "production" # Will be converted to "prod"
  prefix         = "acme"
  suffix         = "v1"
  separator      = "-"
  clean_input    = true
  passthrough    = false

  regions = {
    region1 = "eastus" # Will be converted to "eus"
    region2 = "westus" # Will be converted to "wus"
  }

  # Hybrid naming configuration with custom component order
  naming = {
    use_azurecaf            = false
    use_local_module        = true
    allow_resource_override = true
    validate                = true
    component_order         = ["name", "abbreviation", "environment", "region", "instance", "prefix", "suffix"]
  }
}

resource_groups = {
  prod = {
    name     = "prod-rg"
    location = "eastus"
  }
}

ai_services = {
  # Service with global custom order
  global_custom_service = {
    name               = "chatbot"
    sku_name           = "S0"
    resource_group_key = "prod"
    instance           = "01"
    # Uses global component_order: ["name", "abbreviation", "environment", "region", "instance", "prefix", "suffix"]
    # Result: chatbot-ai-prod-eus-01-acme-v1
  }

  # Service with resource-specific custom order (individual override)
  resource_custom_service = {
    name               = "analyzer"
    sku_name           = "S0"
    resource_group_key = "prod"
    instance           = "02"

    # 🔧 Individual naming override with custom component order
    naming = {
      environment     = "staging" # Override global environment
      region          = "westus"  # Override global region
      component_order = ["prefix", "name", "environment", "region", "instance", "suffix"]
    }
    # Result: acme-analyzer-stg-wus-02-v1
  }

  # Service with minimal components (individual override)
  minimal_service = {
    name               = "simple"
    sku_name           = "S0"
    resource_group_key = "prod"

    # 🎨 Minimal naming configuration
    naming = {
      component_order = ["name", "abbreviation", "environment"]
      # No region, instance, prefix, or suffix
    }
    # Result: simple-ai-prod
  }

  # Service with completely custom pattern
  complex_custom = {
    name               = "processor"
    sku_name           = "S0"
    resource_group_key = "prod"
    instance           = "03"

    # 🚀 Complex custom naming
    naming = {
      prefix          = "org"  # Override global prefix
      suffix          = "beta" # Override global suffix
      separator       = "_"    # Override global separator
      environment     = "dev"  # Override global environment
      component_order = ["abbreviation", "prefix", "name", "environment", "instance", "suffix"]
    }
    # Result: ai_org_processor_dev_03_beta
  }
}

# Expected results with hybrid naming system:
# - global_custom_service: chatbot-ai-prod-eus-01-acme-v1 (uses global component_order)
# - resource_custom_service: acme-analyzer-stg-wus-02-v1 (individual override)
# - minimal_service: simple-ai-prod (minimal components only)
# - complex_custom: ai_org_processor_dev_03_beta (complex custom pattern)
