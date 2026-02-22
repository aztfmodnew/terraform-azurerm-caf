resource "azurecaf_name" "assignment_dynamic_scope" {
  name          = var.settings.name
  resource_type = "general"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  use_slug      = try(var.global_settings.use_slug, false)
  clean_input   = true
  separator     = try(var.global_settings.separator, "-")
}
