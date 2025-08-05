output "admin_assigned" {
  value = local.valid_admin
  description = "Whether the SQL MI administrator was successfully assigned"
}

output "object_id" {
  value = local.object_id
  description = "The object ID of the assigned administrator"
}

output "display_name" {
  value = local.display_name
  description = "The display name of the assigned administrator"
}
