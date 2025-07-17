# Resource Pattern Specialization Example
# Demonstrates different naming patterns optimized for different Azure resource types

global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "azure"
  suffix         = "v1"
  separator      = "-"
  clean_input    = true
  passthrough    = false

  regions = {
    region1 = "westeurope"
    region2 = "eastus"
  }

  # Resource-specific naming patterns
  naming = {
    use_azurecaf              = false
    use_local_module          = true
    allow_resource_override   = true
    validate                  = true
    component_order           = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

    # Specialized patterns for different Azure resource types
    resource_patterns = {
      # Storage accounts: No separators, shorter names due to Azure constraints
      azurerm_storage_account = {
        separator       = ""
        component_order = ["prefix", "name", "environment", "instance"]
        clean_input     = true
        validate        = true
      }

      # Key vaults: Hyphen separators, include region for global uniqueness
      azurerm_key_vault = {
        separator       = "-"
        component_order = ["prefix", "name", "environment", "region"]
        clean_input     = true
        validate        = true
      }

      # Container apps: Underscore separators, full component set
      azurerm_container_app_environment = {
        separator       = "_"
        component_order = ["prefix", "abbreviation", "name", "environment", "instance", "suffix"]
        clean_input     = true
        validate        = true
      }

      # Virtual networks: Hyphen separators, include region and instance
      azurerm_virtual_network = {
        separator       = "-"
        component_order = ["prefix", "abbreviation", "name", "environment", "region", "instance"]
        clean_input     = true
        validate        = true
      }

      # App services: Hyphen separators, exclude region for simplicity
      azurerm_linux_web_app = {
        separator       = "-"
        component_order = ["prefix", "abbreviation", "name", "environment", "suffix"]
        clean_input     = true
        validate        = true
      }

      # SQL databases: Hyphen separators, include instance for scaling
      azurerm_mssql_database = {
        separator       = "-"
        component_order = ["prefix", "name", "environment", "instance", "suffix"]
        clean_input     = true
        validate        = true
      }
    }
  }
}
