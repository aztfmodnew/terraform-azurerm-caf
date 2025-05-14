resource "azurerm_palo_alto_local_rulestack_certificate" "cert" {
  for_each = try(var.settings.certificates, {})

  name         = each.key
  rulestack_id = azurerm_palo_alto_local_rulestack.rulestack.id
  self_signed  = each.value.self_signed

  # Removed unsupported argument: key_vault_secret_id
  audit_comment = try(each.value.audit_comment, null)
  description   = try(each.value.description, null)

  # Ensure compliance: Add timeouts block
  timeouts {
    create = "30m"
    read   = "5m"
    update = "30m"
    delete = "30m"
  }
}
