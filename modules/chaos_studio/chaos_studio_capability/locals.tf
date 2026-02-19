locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  # Resolve landing zone and resource keys
  lz_key     = try(var.settings.chaos_studio_target.lz_key, var.client_config.landingzone_key)
  target_key = try(var.settings.chaos_studio_target.key, var.settings.chaos_studio_target_key, null)

  # Resolve chaos_studio_target_id using remote_objects
  chaos_studio_target_id = try(
    var.settings.chaos_studio_target_id,
    var.remote_objects.chaos_studio_targets[local.lz_key][local.target_key].id,
    null
  )
}
