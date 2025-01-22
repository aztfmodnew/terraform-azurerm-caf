resource "azurerm_network_manager" "network_manager" {
  name                = var.settings.name
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = merge(local.tags, try(var.settings.tags, null))

  scope {
    management_group_ids = try(var.settings.management_group_ids, null)
    subscription_ids = coalesce(
      try(var.settings.scope.subscription_ids, null),
      try([for sub in var.settings.subscriptions : "/subscriptions/${var.remote_objects.subscriptions[try(sub.lz_key, var.client_config.landingzone_key)][sub.key].subscription_id}"], null),
      ["/subscriptions/${var.client_config.subscription_id}"]
    )
  }

  scope_accesses = var.settings.scope_accesses
  description    = var.settings.description
}