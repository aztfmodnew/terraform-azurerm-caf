output "id" {
  value = azurerm_pim_active_role_assignment.this.id
}

output "principal_id" {
  value = azurerm_pim_active_role_assignment.this.principal_id
}

output "principal_type" {
  value = try(azurerm_pim_active_role_assignment.this.principal_type, null)
}
