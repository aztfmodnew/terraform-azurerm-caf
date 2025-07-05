# route.tf
# azurerm_cdn_frontdoor_route resource implementation

resource "azurerm_cdn_frontdoor_route" "route" {
  name = azurecaf_name.route.result
  cdn_frontdoor_endpoint_id = coalesce(
    try(var.settings.cdn_frontdoor_endpoint_id, null),
    try(var.remote_objects.cdn_frontdoor_endpoints[var.settings.endpoint_key].id, null),
    try(var.remote_objects.cdn_frontdoor_endpoints[try(var.settings.endpoint.lz_key, var.client_config.landingzone_key)][var.settings.endpoint.key].id, null)
  )
  cdn_frontdoor_origin_group_id = coalesce(
    try(var.settings.cdn_frontdoor_origin_group_id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)][var.settings.origin_group.key].id, null)
  )
  cdn_frontdoor_origin_ids = coalesce(
    try(var.settings.cdn_frontdoor_origin_ids, null),
    try([
      for origin_key in try(var.settings.origin_ids, []) :
      var.remote_objects.cdn_frontdoor_origins[origin_key].id
    ], null)
  )
  patterns_to_match   = var.settings.patterns_to_match
  supported_protocols = var.settings.supported_protocols

  forwarding_protocol             = try(var.settings.forwarding_protocol, "MatchRequest")
  cdn_frontdoor_custom_domain_ids = try(var.settings.cdn_frontdoor_custom_domain_ids, null)
  cdn_frontdoor_origin_path       = try(var.settings.cdn_frontdoor_origin_path, null)
  cdn_frontdoor_rule_set_ids = try([
    for rule_set_key in try(var.settings.rule_set_keys, []) :
    try(var.remote_objects.cdn_frontdoor_rule_sets[rule_set_key].id, null)
  ], var.settings.cdn_frontdoor_rule_set_ids, null)
  enabled                = try(var.settings.enabled, true)
  https_redirect_enabled = try(var.settings.https_redirect_enabled, true)
  link_to_default_domain = try(var.settings.link_to_default_domain, true)

  dynamic "cache" {
    for_each = try(var.settings.cache, null) == null ? [] : [var.settings.cache]
    content {
      query_string_caching_behavior = try(cache.value.query_string_caching_behavior, "IgnoreQueryString")
      query_strings                 = try(cache.value.query_strings, null)
      compression_enabled           = try(cache.value.compression_enabled, false)
      content_types_to_compress     = try(cache.value.content_types_to_compress, null)
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
