# Hybrid naming system for AI Services
# Supports three naming methods: passthrough, azurecaf, and local module

locals {
  # Determine naming method based on global settings
  use_passthrough   = var.global_settings.passthrough
  use_azurecaf      = !local.use_passthrough && try(var.global_settings.naming.use_azurecaf, true)
  use_local_module  = !local.use_passthrough && !local.use_azurecaf && try(var.global_settings.naming.use_local_module, false)
  
  # Base name from settings
  base_name = var.settings.name
}

# Local naming module (conditional)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0
  
  resource_type   = "azurerm_ai_services"
  name            = local.base_name
  environment     = try(var.settings.environment, var.global_settings.environment, "")
  region          = try(var.settings.region, try(var.global_settings.regions[var.global_settings.default_region], ""), "")
  instance        = try(var.settings.instance, "")
  prefix          = try(var.settings.prefix, try(var.global_settings.prefix, ""))
  suffix          = try(var.settings.suffix, try(var.global_settings.suffix, ""))
  separator       = var.global_settings.separator
  component_order = try(var.global_settings.naming.component_order, var.settings.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"])
  clean_input     = var.global_settings.clean_input
  validate        = true
}

# azurecaf naming (uses cognitive_account as fallback since ai_services is not supported)
resource "azurecaf_name" "ai_services" {
  count = local.use_azurecaf ? 1 : 0
  
  name          = local.base_name
  resource_type = "azurerm_cognitive_account"  # Changed from azurerm_ai_services to azurerm_cognitive_account
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}

# Final name resolution with priority:
# 1. Passthrough: Use original name
# 2. Local module: Use local naming module result
# 3. Azurecaf: Use azurecaf result
# 4. Fallback: Use original name
locals {
  final_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? module.local_naming[0].result : (
      local.use_azurecaf ? azurecaf_name.ai_services[0].result : local.base_name
    )
  )
  
  # Naming method for debugging/monitoring
  naming_method = local.use_passthrough ? "passthrough" : (
    local.use_local_module ? "local_module" : (
      local.use_azurecaf ? "azurecaf" : "fallback"
    )
  )
  
  # Preview name (best effort calculation for plan visibility)
  preview_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? "preview-not-available" : (
      local.use_azurecaf ? join("-", compact([
        try(var.global_settings.prefixes[0], ""),
        "cog",  # abbreviation for cognitive services
        local.base_name,
        try(var.global_settings.suffixes[0], "")
      ])) : local.base_name
    )
  )
}

# Naming information is displayed through outputs
# The preview_name is calculated here and exposed via output

# Use terraform_data to show naming information during plan
resource "terraform_data" "naming_preview" {
  input = {
    base_name     = local.base_name
    naming_method = local.naming_method
    preview_name  = local.preview_name
    final_name    = local.final_name
  }
}