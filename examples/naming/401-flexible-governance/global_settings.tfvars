# Flexible Governance Example
# Allows individual resource overrides while maintaining organizational standards

global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "org"
  suffix         = "001"
  separator      = "-"
  clean_input    = true
  passthrough    = false

  regions = {
    region1 = "westeurope"
    region2 = "eastus"
  }

  # Flexible governance configuration
  naming = {
    use_azurecaf            = false
    use_local_module        = true
    allow_resource_override = true # 🔧 Allows individual overrides
    validate                = true
    component_order         = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

    # Resource-specific patterns (optional defaults)
    resource_patterns = {
      azurerm_storage_account = {
        separator       = "" # Storage accounts don't allow separators
        component_order = ["prefix", "name", "environment", "instance"]
      }
      azurerm_key_vault = {
        separator       = "-"
        component_order = ["prefix", "name", "environment", "suffix"]
      }
    }
  }
}
