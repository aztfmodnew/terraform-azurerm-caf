locals {
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    try(var.settings.tags, null)
  ) : try(var.settings.tags, null)

  location            = coalesce(var.location, try(var.resource_group.location, null))
  resource_group_name = coalesce(var.resource_group_name, try(var.resource_group.name, null))

  redis_role_assignments_flat = {
    for role_name, role_data in try(var.settings.redis_role_assignment, {}) :
    role_name => [
      for key in role_data.managed_identities.keys : {
        assignment_key = format("%s:%s", role_name, key)

        lz_key = coalesce(try(role_data.managed_identities.lz_key, null), var.client_config.landingzone_key)

        principal_id = var.remote_objects.managed_identities[coalesce(try(role_data.managed_identities.lz_key, null), var.client_config.landingzone_key)][key].principal_id
      }
    ]
  }

  redis_role_assignments_merged = flatten([for v in values(local.redis_role_assignments_flat) : v])
}
