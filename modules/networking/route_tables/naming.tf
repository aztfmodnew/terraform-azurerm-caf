# Hybrid naming system for azurerm_route_table
# Supports three naming methods: passthrough, azurecaf, and local module
# With individual resource override capability and governance controls

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

  # Resource type for pattern lookup
  resource_type = "azurerm_route_table"

  # Control de governance - permite override individual
  allow_individual_override = try(var.global_settings.naming.allow_resource_override, true)

  # Hybrid naming configuration with fallback hierarchy:
  # settings.naming → global resource patterns → global defaults
  effective_naming = local.allow_individual_override ? {
    environment = try(var.settings.naming.environment, var.global_settings.environment)
    region      = try(var.settings.naming.region, try(var.global_settings.regions[var.global_settings.default_region], ""))
    instance    = try(var.settings.naming.instance, try(var.settings.instance, ""))
    prefix      = try(var.settings.naming.prefix, var.global_settings.prefix)
    suffix      = try(var.settings.naming.suffix, var.global_settings.suffix)
    separator = try(var.settings.naming.separator,
    try(var.global_settings.naming.resource_patterns[local.resource_type].separator, var.global_settings.separator))
    component_order = try(var.settings.naming.component_order,
    try(var.global_settings.naming.resource_patterns[local.resource_type].component_order, var.global_settings.naming.component_order))
    clean_input = try(var.settings.naming.clean_input, var.global_settings.clean_input)
    validate    = try(var.settings.naming.validate, var.global_settings.naming.validate)
    } : {
    # Modo controlado - solo patrones globales (no override individual)
    environment     = var.global_settings.environment
    region          = try(var.global_settings.regions[var.global_settings.default_region], "")
    instance        = try(var.settings.instance, "")
    prefix          = var.global_settings.prefix
    suffix          = var.global_settings.suffix
    separator       = try(var.global_settings.naming.resource_patterns[local.resource_type].separator, var.global_settings.separator)
    component_order = try(var.global_settings.naming.resource_patterns[local.resource_type].component_order, var.global_settings.naming.component_order)
    clean_input     = var.global_settings.clean_input
    validate        = var.global_settings.naming.validate
  }
}

# Local naming module (conditional)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = local.resource_type
  name            = local.base_name
  environment     = local.effective_naming.environment
  region          = local.effective_naming.region
  instance        = local.effective_naming.instance
  prefix          = local.effective_naming.prefix
  suffix          = local.effective_naming.suffix
  separator       = local.effective_naming.separator
  component_order = local.effective_naming.component_order
  clean_input     = local.effective_naming.clean_input
  validate        = local.effective_naming.validate
}

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "main_resource" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_route_table"
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

  # Additional metadata for governance and debugging
  naming_config = {
    effective_naming = local.effective_naming
    allow_override   = local.allow_individual_override
    resource_type    = local.resource_type
    base_name        = local.base_name
    final_name       = local.final_name
    naming_method    = local.naming_method
  }
}
