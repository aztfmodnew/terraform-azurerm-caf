resource "azurerm_palo_alto_local_rulestack_fqdn_list" "local_rulestack_fqdn_list" {
  for_each = try(var.settings.fqdn_lists, {})

  name                         = each.key
  rulestack_id                 = azurerm_palo_alto_local_rulestack.local_rulestack.id
  fully_qualified_domain_names = try(each.value.fully_qualified_domain_names, [])
  audit_comment                = try(each.value.audit_comment, null)
  description                  = try(each.value.description, null)
}
