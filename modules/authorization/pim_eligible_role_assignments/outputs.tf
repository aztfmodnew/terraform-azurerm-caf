output "id" {
  description = "The ID of the PIM Eligible Role Assignment."
  value       = azurerm_pim_eligible_role_assignment.pim_eligible_role_assignment.id
}

output "principal_type" {
  description = "The type of principal (User, Group, ServicePrincipal)."
  value       = azurerm_pim_eligible_role_assignment.pim_eligible_role_assignment.principal_type
}
