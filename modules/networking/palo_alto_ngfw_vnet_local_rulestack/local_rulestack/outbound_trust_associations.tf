resource "azurerm_palo_alto_local_rulestack_outbound_trust_certificate_association" "trust_assoc" {
  for_each = try(var.settings.outbound_trust_certificate_associations, {})

  name             = each.key # Terraform resource name for the association
  rulestack_id     = azurerm_palo_alto_local_rulestack.rulestack.id
  certificate_name = each.value.certificate_name
}
