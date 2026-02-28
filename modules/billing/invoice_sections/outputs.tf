output "id" {
  description = "The ID of the invoice section."
  value       = azapi_resource.invoice_section.id
}

output "name" {
  description = "The name of the invoice section."
  value       = azapi_resource.invoice_section.name
}

output "display_name" {
  description = "The display name of the invoice section."
  value       = var.settings.name
}

output "billing_account_id" {
  description = "The billing account ID."
  value       = var.settings.billing_account_id
}

output "billing_profile_id" {
  description = "The billing profile ID."
  value       = var.settings.billing_profile_id
}
