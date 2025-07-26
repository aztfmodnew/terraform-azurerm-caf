# Hybrid naming system for azurerm_ai_services
# Supports three naming methods: passthrough, azurecaf, and local module

locals {
  # Determine naming method based on global settings priority:
  # 1. Passthrough (exact names)
  # 2. Local module (configurable CAF naming)
  # 3. Azurecaf (provider-based CAF naming)
  # 4. Fallback (original name)
  use_passthrough  = var.global_settings.passthrough
  use_local_module = !local.use_passthrough && try(var.global_settings.naming.use_local_module, false)
  use_azurecaf     = !local.use_passthrough && !local.use_local_module && try(var.global_settings.naming.use_azurecaf, true)

  # Base name from settings
  base_name = var.settings.name
}

# Local naming module (conditional)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = "azurerm_ai_services"
  name            = local.base_name
  environment     = var.global_settings.environment
  region          = try(var.global_settings.regions[var.global_settings.default_region], "")
  instance        = try(var.settings.instance, "")
  prefix          = var.global_settings.prefix
  suffix          = var.global_settings.suffix
  separator       = var.global_settings.separator
  component_order = var.global_settings.naming.component_order
  clean_input     = var.global_settings.clean_input
  validate        = var.global_settings.naming.validate
}

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "main_resource" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_cognitive_account" # Use closest supported type if exact type not available
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}

# Final name resolution with priority
locals {
  final_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? module.local_naming[0].result : (
      local.use_azurecaf ? azurecaf_name.main_resource[0].result : local.base_name
    )
  )

  # Naming method for debugging/monitoring
  naming_method = local.use_passthrough ? "passthrough" : (
    local.use_local_module ? "local_module" : (
      local.use_azurecaf ? "azurecaf" : "fallback"
    )
  )

  # Debug information
  naming_debug = {
    base_name        = local.base_name
    final_name       = local.final_name
    naming_method    = local.naming_method
    use_passthrough  = local.use_passthrough
    use_local_module = local.use_local_module
    use_azurecaf     = local.use_azurecaf
    debug_message    = "This resource is using ${local.naming_method} naming method"
  }
}
