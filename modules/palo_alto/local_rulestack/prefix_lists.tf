resource "azurerm_palo_alto_local_rulestack_prefix_list" "prefixlist" {
  for_each      = try(var.settings.prefix_lists, {})
  name          = each.key
  rulestack_id  = azurerm_palo_alto_local_rulestack.rulestack.id
  prefix_list   = try(each.value.prefix_list, null)
  audit_comment = try(each.value.audit_comment, null)
  description   = try(each.value.description, null)
}
