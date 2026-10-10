output "id" {
  description = "The group membership ID."
  value       = azuread_group_member.id.id
}

output "resource" {
  description = "The group membership resource."
  value       = azuread_group_member.id
}
