resource "azurerm_palo_alto_local_rulestack_outbound_untrust_certificate_association" "local_rulestack_outbound_untrust_certificate_association" {
  for_each = try(var.settings.outbound_untrust_certificate_associations, {})

  certificate_id = try(azurerm_palo_alto_local_rulestack_certificate.local_rulestack_certificate[each.value.certificate_key].id, null)

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
