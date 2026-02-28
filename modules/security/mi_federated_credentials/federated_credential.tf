resource "azurerm_federated_identity_credential" "fed_cred" {
  name     = var.settings.name
  audience = try(var.settings.audience, null) == null ? ["api://AzureADTokenExchange"] : var.settings.audience
  parent_id = coalesce(
    try(var.settings.managed_identity.id, null),
    var.managed_identities[coalesce(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.managed_identity.key].id
  )
  subject = var.settings.subject
  issuer = coalesce(
    try(var.settings.oidc_issuer_url, null),
    var.oidc_issuer_url
  )

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
