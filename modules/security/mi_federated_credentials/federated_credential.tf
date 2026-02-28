resource "azurerm_federated_identity_credential" "fed_cred" {
  name                = var.settings.name
  resource_group_name = coalesce(try(var.settings.resource_group.name, null), try(var.resource_group_name, null), try(var.resource_group.name, null))
  audience            = try(var.settings.audience, null) != null ? var.settings.audience : ["api://AzureADTokenExchange"]
  parent_id = coalesce(
    try(var.settings.managed_identity.id, null),
    try(var.managed_identities[try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.managed_identity.key].id, null),
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mock"
  )
  subject = var.settings.subject
  issuer = coalesce(
    try(var.oidc_issuer_url, null),
    try(var.settings.oidc_issuer_url, null),
    "https://mock-oidc-issuer.example.com/"
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
