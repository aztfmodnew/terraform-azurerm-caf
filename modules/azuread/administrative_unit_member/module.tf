resource "azuread_administrative_unit_member" "admum" {
  administrative_unit_object_id = coalesce(
    var.settings.administrative_unit_object.id,
    try(var.remote_objects.azuread_administrative_units[coalesce(var.settings.administrative_unit_object.lz_key, var.client_config.landingzone_key)][var.settings.administrative_unit_object.key].object_id, null)
  )
  member_object_id = coalesce(
    var.settings.member_object.id,
    try(var.remote_objects[var.settings.member_object.resource_type][coalesce(var.settings.member_object.lz_key, var.client_config.landingzone_key)][var.settings.member_object.key].object_id, null)
  )

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}