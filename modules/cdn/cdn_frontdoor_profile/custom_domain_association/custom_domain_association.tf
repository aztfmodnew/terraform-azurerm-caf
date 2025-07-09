# custom_domain_association.tf
resource "azurerm_cdn_frontdoor_custom_domain_association" "custom_domain_association" {
  cdn_frontdoor_custom_domain_id = coalesce(
    try(var.settings.cdn_frontdoor_custom_domain_id, null),
    try(var.remote_objects.cdn_frontdoor_custom_domains[var.settings.cdn_frontdoor_custom_domain_key].id, null),
    try(var.remote_objects.cdn_frontdoor_custom_domains[try(var.settings.cdn_frontdoor_custom_domain.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_custom_domain.key].id, null)
  )

  cdn_frontdoor_route_ids = coalesce(
    var.settings.cdn_frontdoor_route_ids,
    [
      for route_key in try(var.settings.cdn_frontdoor_route_keys, []) :
      try(var.remote_objects.cdn_frontdoor_routes[route_key].id, null)
    ]
  )

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
