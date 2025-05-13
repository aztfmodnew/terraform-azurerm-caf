resource "azurerm_palo_alto_local_rulestack_certificate" "cert" {
  for_each = try(var.settings.certificates, {})

  name         = each.key
  rulestack_id = azurerm_palo_alto_local_rulestack.rulestack.id
  self_signed  = each.value.self_signed

  key_vault_secret_id = try(each.value.key_vault_secret_id, null)
  audit_comment       = try(each.value.audit_comment, null)
  description         = try(each.value.description, null)
}
