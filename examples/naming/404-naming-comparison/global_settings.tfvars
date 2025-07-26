# Naming Method Comparison Example
# Demonstrates all three naming methods side by side for comparison

global_settings = {
  default_region = "region1"
  environment    = "test"
  prefix         = "comp"
  suffix         = "demo"
  separator      = "-"
  clean_input    = true
  passthrough    = false

  regions = {
    region1 = "westeurope"
  }

  # Configuration supports all naming methods
  naming = {
    use_azurecaf            = false # Primary method: local_module
    use_local_module        = true
    allow_resource_override = true
    validate                = true
    component_order         = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]

    resource_patterns = {
      azurerm_storage_account = {
        separator       = ""
        component_order = ["prefix", "name", "environment", "instance"]
      }
    }
  }
}
