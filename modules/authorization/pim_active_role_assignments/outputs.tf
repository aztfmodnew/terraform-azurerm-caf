output "id" {
  description = "The ID of the PIM Active Role Assignment."
  value       = azurerm_pim_active_role_assignment.pim_active_role_assignment.id
}

output "principal_type" {
  description = "The type of principal (User, Group, ServicePrincipal)."
  value       = azurerm_pim_active_role_assignment.pim_active_role_assignment.principal_type
}
