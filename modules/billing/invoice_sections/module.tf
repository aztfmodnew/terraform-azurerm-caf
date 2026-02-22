# Ref: https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource
# Ref: https://learn.microsoft.com/en-us/rest/api/billing/invoice-sections

resource "azapi_resource" "invoice_section" {
  name      = var.settings.name
  type      = "Microsoft.Billing/billingAccounts/billingProfiles/invoiceSections@2020-05-01"
  parent_id = "/providers/Microsoft.Billing/billingAccounts/${var.settings.billing_account_id}/billingProfiles/${var.settings.billing_profile_id}"

  schema_validation_enabled = false

  body = {
    properties = {
      labels      = try(var.settings.labels, {})
      displayName = var.settings.name
    }
  }

  tags = local.tags
}

output "id" {
  value = azapi_resource.invoice_section.id
}

output "name" {
  value = azapi_resource.invoice_section.name
}

output "display_name" {
  value = var.settings.name
}

output "billing_account_id" {
  value = var.settings.billing_account_id
}

output "billing_profile_id" {
  value = var.settings.billing_profile_id
}
