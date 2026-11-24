locals {
  event_hub_identities = try(
    var.settings.identity.type != null ? [var.settings.identity] : [],
    [for identity in var.settings.identity : identity],
    []
  )

  managed_local_identities = flatten([
    for identity in local.event_hub_identities : [
      for managed_identity_key in try(identity.managed_identity_keys, []) : [
        var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
      ]
    ]
  ])

  managed_remote_identities = flatten([
    for identity in local.event_hub_identities : [
      for lz_key, value in try(identity.remote, {}) : [
        for managed_identity_key in value.managed_identity_keys : [
          var.remote_objects.managed_identities[lz_key][managed_identity_key].id
        ]
      ]
    ]
  ])

  managed_identities = concat(local.managed_local_identities, local.managed_remote_identities)
}
