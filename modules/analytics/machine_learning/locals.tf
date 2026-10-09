locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = merge(var.base_tags, local.module_tag, coalesce(try(var.settings.tags, null), {}))

  resource_group = coalesce(
    try(var.resource_groups[var.client_config.landingzone_key][var.settings.resource_group_key], null),
    try(var.resource_groups[var.settings.lz_key][var.settings.resource_group_key], null),
    try(var.resource_groups[var.client_config.landingzone_key][var.settings.resource_group.key], null),
    try(var.resource_groups[var.settings.resource_group.lz_key][var.settings.resource_group.key], null),
    try(var.settings.resource_group, {})
  )

  location = coalesce(
    try(var.settings.location, null),
    try(var.global_settings.regions[var.settings.region], null),
    try(local.resource_group.location, null)
  )

  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(local.resource_group.name, null)
  )

  identity_type = coalesce(try(var.settings.identity.type, null), "SystemAssigned")

  local_managed_identity_ids = flatten([
    for key in try(var.settings.identity.managed_identity_keys, []) : [
      var.remote_objects.managed_identities[var.client_config.landingzone_key][key].id
    ]
  ])

  remote_managed_identity_ids = flatten([
    for lz_key, identity_set in try(var.settings.identity.remote, {}) : [
      for key in try(identity_set.managed_identity_keys, []) : [
        var.remote_objects.managed_identities[lz_key][key].id
      ]
    ]
  ])

  identity_ids = distinct(concat(
    try(var.settings.identity.identity_ids, []),
    local.local_managed_identity_ids,
    local.remote_managed_identity_ids
  ))

  network_outbound_rules = try(var.settings.network_outbound_rules, {})
}
