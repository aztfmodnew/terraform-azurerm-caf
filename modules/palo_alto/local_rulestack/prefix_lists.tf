resource "azurerm_palo_alto_local_rulestack_prefix_list" "local_rulestack_prefix_list" {
  for_each      = try(var.settings.prefix_lists, {})
  name          = each.key
  rulestack_id  = azurerm_palo_alto_local_rulestack.local_rulestack.id
  prefix_list   = try(each.value.prefix_list, [])
  audit_comment = try(each.value.audit_comment, null)
  description   = try(each.value.description, null)
  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
