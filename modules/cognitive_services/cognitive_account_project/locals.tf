locals {
  module_tag = {
    module = basename(abspath(path.module))
  }

  tags = var.base_tags ? merge(
    try(var.global_settings.tags, {}),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags, null)
  )

  location = coalesce(
    try(var.settings.location, null),
    try(var.settings.region, null),
    try(var.global_settings.regions[try(var.settings.region_key, var.global_settings.default_region)], null)
  )

  managed_identity_type = try(var.settings.identity.type, "SystemAssigned")

  managed_local_identities = flatten([
    for managed_identity_key in try(var.settings.identity.managed_identity_keys, []) : [
      var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
    ]
  ])

  managed_remote_identities = flatten([
    for lz_key, value in try(var.settings.identity.remote, {}) : [
      for managed_identity_key in try(value.managed_identity_keys, []) : [
        var.remote_objects.managed_identities[lz_key][managed_identity_key].id
      ]
    ]
  ])

  managed_identities = concat(
    local.managed_local_identities,
    local.managed_remote_identities,
    try(var.settings.identity.identity_ids, [])
  )
}
