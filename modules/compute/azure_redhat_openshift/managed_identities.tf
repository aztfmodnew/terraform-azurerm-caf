locals {
  managed_local_identities = [
    for key in coalesce(try(var.settings.identity.managed_identity_keys, null), []) :
    var.combined_resources.managed_identities[var.client_config.landingzone_key][key].id
  ]
  managed_remote_identities = flatten([
    for lz_key, value in coalesce(try(var.settings.identity.remote, null), {}) : [
      for key in value.managed_identity_keys :
      var.combined_resources.managed_identities[lz_key][key].id
    ]
  ])
  managed_identities = concat(
    coalesce(try(var.settings.identity.identity_ids, null), []),
    local.managed_local_identities,
    local.managed_remote_identities
  )
}
