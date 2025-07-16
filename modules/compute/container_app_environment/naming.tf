# Hybrid naming system for container_app_environment
# Supports three naming methods: passthrough, azurecaf, and local module

locals {
  # Determine naming method based on global settings priority:
  # 1. Passthrough (exact names)
  # 2. Local module (configurable CAF naming)
  # 3. Azurecaf (provider-based CAF naming)
  # 4. Fallback (original name)
  use_passthrough   = var.global_settings.passthrough
  use_local_module  = !local.use_passthrough && try(var.global_settings.naming.use_local_module, false)
  use_azurecaf      = !local.use_passthrough && !local.use_local_module && try(var.global_settings.naming.use_azurecaf, true)

  # Base name from settings
  base_name = var.settings.name
}

# Local naming module (conditional)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = "azurerm_container_app_environment"
  name            = local.base_name
  environment     = try(var.settings.environment, var.global_settings.environment, "")
  region          = try(var.settings.region, try(var.global_settings.regions[var.global_settings.default_region], ""), "")
  instance        = try(var.settings.instance, "")
  prefix          = try(var.settings.prefix, try(var.global_settings.prefix, ""))
  suffix          = try(var.settings.suffix, try(var.global_settings.suffix, ""))
  separator       = var.global_settings.separator
  component_order = try(var.global_settings.naming.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"])
  clean_input     = var.global_settings.clean_input
  validate        = true
}

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "cae" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_container_app_environment"    
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# Final name resolution with priority
locals {
  final_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? module.local_naming[0].result : (
      local.use_azurecaf ? azurecaf_name.cae[0].result : local.base_name
    )
  )

  # Naming method for debugging/monitoring
  naming_method = local.use_passthrough ? "passthrough" : (
    local.use_local_module ? "local_module" : (
      local.use_azurecaf ? "azurecaf" : "fallback"
    )
  )
}

# Preview the naming result for plan-time visibility
resource "terraform_data" "naming_preview" {
  input = {
    final_name     = local.final_name
    naming_method  = local.naming_method
    base_name      = local.base_name
    use_passthrough = local.use_passthrough
    use_local_module = local.use_local_module
    use_azurecaf    = local.use_azurecaf
  }
}
