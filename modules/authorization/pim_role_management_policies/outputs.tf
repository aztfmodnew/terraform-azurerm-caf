output "id" {
  value = azurerm_role_management_policy.this.id
}

output "name" {
  value = azurerm_role_management_policy.this.name
}

output "scope" {
  value = local.scope
}

output "role_definition_id" {
  value = local.role_definition_id
}
