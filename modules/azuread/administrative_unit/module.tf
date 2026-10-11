resource "azuread_administrative_unit" "admu" {
  display_name              = var.settings.display_name
  description               = try(var.settings.description, null)
  prevent_duplicate_names   = try(var.settings.prevent_duplicate_names, null)
  members                   = try(var.settings.members, null)
  hidden_membership_enabled = try(var.settings.hidden_membership_enabled, null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}