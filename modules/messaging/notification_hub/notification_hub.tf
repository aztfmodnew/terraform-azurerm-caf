# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/notification_hub

resource "azurerm_notification_hub" "notification_hub" {
  for_each = try(var.settings.hubs, {})

  name                = each.value.name
  namespace_name      = azurerm_notification_hub_namespace.notification_hub_namespace.name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = merge(local.base_tags, try(each.value.tags, {}))

  dynamic "apns_credential" {
    for_each = try(each.value.apns_credential, {}) != {} ? [1] : []
    content {
      application_mode = each.value.apns_credential.application_mode
      bundle_id        = each.value.apns_credential.bundle_id
      key_id           = each.value.apns_credential.key_id
      team_id          = each.value.apns_credential.team_id
      token            = each.value.apns_credential.token
    }
  }

  dynamic "gcm_credential" {
    for_each = try(each.value.gcm_credential, {}) != {} ? [1] : []
    content {
      api_key = each.value.gcm_credential.api_key
    }
  }
}
