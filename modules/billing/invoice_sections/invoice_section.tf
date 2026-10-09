# Ref: https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource
# Ref: https://learn.microsoft.com/en-us/rest/api/billing/invoice-sections

resource "azapi_resource" "invoice_section" {
  name      = var.settings.name
  type      = "Microsoft.Billing/billingAccounts/billingProfiles/invoiceSections@2024-04-01"
  parent_id = "/providers/Microsoft.Billing/billingAccounts/${var.settings.billing_account_id}/billingProfiles/${var.settings.billing_profile_id}"

  ignore_null_property = true

  body = {
    properties = {
      tags        = merge(local.tags, var.settings.labels, var.settings.tags)
      displayName = coalesce(var.settings.display_name, var.settings.name)
      state       = try(var.settings.state, null)
      reasonCode  = try(var.settings.reason_code, null)
      targetCloud = try(var.settings.target_cloud, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
