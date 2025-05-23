resource "azurerm_palo_alto_local_rulestack_outbound_trust_certificate_association" "trust_assoc" {
  for_each       = try(var.settings.outbound_trust_certificate_associations, {})
  certificate_id = each.value.certificate_id
  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
