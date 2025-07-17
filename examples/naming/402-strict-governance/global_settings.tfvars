# Strict Governance Example
# Enforces organizational naming standards without allowing individual overrides

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
    region2 = "eastus"
  }

  # Strict governance configuration
  naming = {
    use_azurecaf              = false
    use_local_module          = true
    allow_resource_override   = false   # 🔒 No individual overrides allowed
    validate                  = true
    component_order           = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

    # Mandatory resource patterns - enforced for all resources
    resource_patterns = {
      azurerm_storage_account = {
        separator       = ""
        component_order = ["prefix", "name", "environment", "instance"]
        validate        = true
      }
      azurerm_key_vault = {
        separator       = "-"
        component_order = ["prefix", "abbreviation", "name", "environment", "region"]
        validate        = true
      }
      azurerm_container_app_environment = {
        separator       = "-"
        component_order = ["prefix", "abbreviation", "name", "environment", "instance", "suffix"]
        validate        = true
      }
    }
  }
}
