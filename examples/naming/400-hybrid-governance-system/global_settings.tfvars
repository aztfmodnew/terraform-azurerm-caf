# Hybrid Governance Naming System Example
# Demonstrates organizational control with individual flexibility

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
    region2 = "eastus2"
  }

  # 🎯 Hybrid Naming Configuration
  naming = {
    # Primary naming method selection
    use_azurecaf     = false
    use_local_module = true
    validate         = true
    component_order  = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

    # 🔧 Governance Controls
    allow_resource_override = true # Set to false for strict organizational control

    # 🎨 Resource-Specific Patterns
    # These patterns override global defaults for specific resource types
    resource_patterns = {
      azurerm_container_app_environment = {
        separator       = "_"
        component_order = ["prefix", "name", "environment", "instance", "suffix"]
        prefix          = "cae" # Override global prefix for this resource type
      }
      azurerm_storage_account = {
        separator       = "" # No separator for storage accounts (Azure requirement)
        component_order = ["prefix", "name", "environment", "instance"]
        clean_input     = true # Remove invalid characters for storage accounts
      }
      azurerm_key_vault = {
        separator       = "-"
        component_order = ["prefix", "name", "environment", "region"]
        suffix          = "kv" # Always end with 'kv' for key vaults
      }
    }
  }
}
