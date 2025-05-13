resource "azurerm_palo_alto_local_rulestack_fqdn_list" "fqdnlist" {
  for_each = try(var.settings.fqdn_lists, {})

  name         = each.key
  rulestack_id = azurerm_palo_alto_local_rulestack.rulestack.id
  fqdn_entries = each.value.fqdn_entries

  audit_comment = try(each.value.audit_comment, null)
  description   = try(each.value.description, null)
}
