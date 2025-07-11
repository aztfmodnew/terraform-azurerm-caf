# origin.tf
# azurerm_cdn_frontdoor_origin resource implementation

resource "azurerm_cdn_frontdoor_origin" "origin" {
  name = azurecaf_name.origin.result
  cdn_frontdoor_origin_group_id = coalesce(
    try(var.settings.cdn_frontdoor_origin_group_id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.cdn_frontdoor_origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)][var.settings.origin_group.key].id, null)
  )
  host_name = coalesce(
    try(var.settings.host_name, null),
    try(var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.key].primary_web_host, null),
    try(var.remote_objects.storage_accounts[var.client_config.landingzone_key][var.settings.storage_account.key].primary_web_host, null)
  )
  certificate_name_check_enabled = var.settings.certificate_name_check_enabled
  enabled                        = try(var.settings.enabled, true)
  http_port                      = try(var.settings.http_port, 80)
  https_port                     = try(var.settings.https_port, 443)
  origin_host_header = coalesce(
    try(var.settings.origin_host_header, null),
    try(var.remote_objects.storage_accounts[try(var.settings.storage_account.lz_key, var.client_config.landingzone_key)][var.settings.storage_account.key].primary_web_host, null),
    try(var.remote_objects.storage_accounts[var.client_config.landingzone_key][var.settings.storage_account.key].primary_web_host, null)
  )
  priority = try(var.settings.priority, 1)
  weight   = try(var.settings.weight, 500)

  # Lifecycle rule to prevent premature destruction when associated with routes
  lifecycle {
    create_before_destroy = true
  }

  dynamic "private_link" {
    for_each = try(var.settings.private_link, null) == null ? [] : [var.settings.private_link]
    content {
      request_message        = try(private_link.value.request_message, "Access request for CDN FrontDoor Private Link Origin")
      target_type            = try(private_link.value.target_type, null)
      location               = private_link.value.location
      private_link_target_id = private_link.value.private_link_target_id
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
