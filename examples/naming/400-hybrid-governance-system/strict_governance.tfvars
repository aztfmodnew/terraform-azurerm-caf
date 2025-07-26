# Strict Governance Mode Example
# Demonstrates organizational control with NO individual overrides allowed

global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "corp"
  suffix         = "001"
  separator      = "-"
  clean_input    = true
  passthrough    = false

  regions = {
    region1 = "westeurope"
  }

  # 🔒 Strict Governance Configuration
  naming = {
    use_azurecaf     = false
    use_local_module = true
    validate         = true
    component_order  = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

    # 🔒 Strict Control - NO individual overrides allowed
    allow_resource_override = false

    # Only resource patterns and global settings apply
    resource_patterns = {
      azurerm_container_app_environment = {
        separator       = "_"
        component_order = ["prefix", "name", "environment", "instance", "suffix"]
        prefix          = "cae"
      }
    }
  }
}
