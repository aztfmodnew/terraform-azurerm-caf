resource "azurerm_palo_alto_local_rulestack_certificate" "local_rulestack_certificate" {
  for_each = try(var.settings.certificates, {})

  name         = each.key
  rulestack_id = azurerm_palo_alto_local_rulestack.local_rulestack.id
  self_signed  = each.value.self_signed
  key_vault_certificate_id = each.value.self_signed == false ? try(
    #data.azurerm_key_vault_certificate.manual_certs[each.key].secret_id,
    var.remote_objects.keyvault_certificates[each.value.key_vault_secret.lz_key][each.value.key_vault_secret.certificate_key].versionless_id,
    var.remote_objects.keyvault_certificates[var.client_config.landingzone_key][each.value.key_vault_secret.certificate_key].versionless_id,
    var.remote_objects.keyvault_certificate_requests[each.value.key_vault_secret.lz_key][each.value.key_vault_secret.certificate_request_key].versionless_id,
    var.remote_objects.keyvault_certificate_requests[var.client_config.landingzone_key][each.value.key_vault_secret.certificate_request_key].versionless_id,
    each.value.key_vault_certificate_id,
    null
  ) : null
  audit_comment = try(each.value.audit_comment, null)
  description   = try(each.value.description, null)

  # Ensure compliance: Add timeouts block
  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
