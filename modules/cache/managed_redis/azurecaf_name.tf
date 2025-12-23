# CAF naming for Managed Redis
# Note: azurecaf currently has no dedicated resource_type for managed redis; using generic passthrough via azurecaf_name with resource_type "generic".
resource "azurecaf_name" "managed_redis" {
  name          = var.settings.name
  resource_type = try(var.settings.azurecaf_resource_type, "generic")
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
