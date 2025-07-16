# Hybrid naming system for Storage Account
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
  base_name = var.storage_account.name
}

# Local naming module (conditional)
module "local_naming" {
  source = "../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = "azurerm_storage_account"
  name            = local.base_name
  environment     = try(var.storage_account.environment, var.global_settings.environment, "")
  region          = try(var.storage_account.region, try(var.global_settings.regions[var.global_settings.default_region], ""), "")
  instance        = try(var.storage_account.instance, "")
  prefix          = try(var.storage_account.prefix, try(var.global_settings.prefix, ""))
  suffix          = try(var.storage_account.suffix, try(var.global_settings.suffix, ""))
  separator       = var.global_settings.separator
  component_order = try(var.storage_account.component_order, try(var.global_settings.naming.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]))
  clean_input     = var.global_settings.clean_input
  validate        = true
}

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "storage_account" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_storage_account"
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
      local.use_azurecaf ? azurecaf_name.storage_account[0].result : local.base_name
    )
  )

  # Naming method for debugging/monitoring
  naming_method = local.use_passthrough ? "passthrough" : (
    local.use_local_module ? "local_module" : (
      local.use_azurecaf ? "azurecaf" : "fallback"
    )
  )
}

# Preview name calculation for plan-time visibility
resource "terraform_data" "naming_preview" {
  input = {
    base_name     = local.base_name
    naming_method = local.naming_method
    final_name    = local.final_name
  }
}
