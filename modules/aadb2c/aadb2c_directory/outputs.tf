output "id" {
  value = azurerm_aadb2c_directory.aadb2c.id
}

output "tenant_id" {
  value = azurerm_aadb2c_directory.aadb2c.tenant_id
}

output "billing_type" {
  value       = azurerm_aadb2c_directory.aadb2c.billing_type
  description = "The billing type of the AAD B2C tenant."
}

output "effective_start_date" {
  value       = azurerm_aadb2c_directory.aadb2c.effective_start_date
  description = "The date from which the billing type took effect; it may be unset until after the first billing cycle."
}