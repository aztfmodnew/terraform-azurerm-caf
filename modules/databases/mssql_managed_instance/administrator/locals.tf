locals {
  object_id = try(var.group_id, data.azuread_user.upn[0].id, null)
  display_name = var.group_id != null ? var.group_name : var.user_principal_name
  
  # Validation - ensure we have a valid object_id
  valid_admin = local.object_id != null && local.object_id != ""
}
