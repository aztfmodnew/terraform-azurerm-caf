# rule.tf
# Placeholder for azurerm_cdn_frontdoor_rule resource implementation

resource "azurerm_cdn_frontdoor_rule" "rule" {
  name = azurecaf_name.rule.result
  cdn_frontdoor_rule_set_id = coalesce(
    try(var.settings.cdn_frontdoor_rule_set_id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[var.settings.rule_set_key].id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[try(var.settings.rule_set.lz_key, var.client_config.landingzone_key)][var.settings.rule_set.key].id, null)
  )
  order             = var.settings.order
  behavior_on_match = try(var.settings.behavior_on_match, "Continue")

  # The actions block is required - create from actions array
  dynamic "actions" {
    for_each = try(var.settings.actions, [])
    content {
      dynamic "url_rewrite_action" {
        for_each = try(actions.value.url_rewrite_action, {}) != {} ? [actions.value.url_rewrite_action] : []
        content {
          destination             = url_rewrite_action.value.destination
          source_pattern          = url_rewrite_action.value.source_pattern
          preserve_unmatched_path = try(url_rewrite_action.value.preserve_unmatched_path, false)
        }
      }

      dynamic "url_redirect_action" {
        for_each = try(actions.value.url_redirect_action, {}) != {} ? [actions.value.url_redirect_action] : []
        content {
          redirect_type        = url_redirect_action.value.redirect_type
          destination_hostname = url_redirect_action.value.destination_hostname
          redirect_protocol    = try(url_redirect_action.value.redirect_protocol, "MatchRequest")
          destination_path     = try(url_redirect_action.value.destination_path, "")
          query_string         = try(url_redirect_action.value.query_string, "")
          destination_fragment = try(url_redirect_action.value.destination_fragment, "")
        }
      }

      dynamic "route_configuration_override_action" {
        for_each = try(actions.value.route_configuration_override_action, {}) != {} ? [actions.value.route_configuration_override_action] : []
        content {
          cache_duration = try(route_configuration_override_action.value.cache_duration, null)
          cdn_frontdoor_origin_group_id = coalesce(
            try(route_configuration_override_action.value.cdn_frontdoor_origin_group_id, null),
            try(var.remote_objects.cdn_frontdoor_origin_groups[route_configuration_override_action.value.origin_group_key].id, null),
            try(var.remote_objects.cdn_frontdoor_origin_groups[try(route_configuration_override_action.value.origin_group.lz_key, var.client_config.landingzone_key)][route_configuration_override_action.value.origin_group.key].id, null)
          )
          forwarding_protocol           = try(route_configuration_override_action.value.forwarding_protocol, null)
          query_string_caching_behavior = try(route_configuration_override_action.value.query_string_caching_behavior, "IgnoreQueryString")
          query_string_parameters       = try(route_configuration_override_action.value.query_string_parameters, null)
          compression_enabled           = try(route_configuration_override_action.value.compression_enabled, null)
          cache_behavior                = try(route_configuration_override_action.value.cache_behavior, "HonorOrigin")
        }
      }

      dynamic "request_header_action" {
        for_each = try(actions.value.request_header_action, [])
        content {
          header_action = request_header_action.value.header_action
          header_name   = request_header_action.value.header_name
          value         = try(request_header_action.value.value, null)
        }
      }

      dynamic "response_header_action" {
        for_each = try(actions.value.response_header_action, [])
        content {
          header_action = response_header_action.value.header_action
          header_name   = response_header_action.value.header_name
          value         = try(response_header_action.value.value, null)
        }
      }
    }
  }

  dynamic "conditions" {
    for_each = try(var.settings.conditions, [])
    content {
      dynamic "remote_address_condition" {
        for_each = try(conditions.value.remote_address_condition, [])
        content {
          operator         = try(remote_address_condition.value.operator, "IPMatch")
          negate_condition = try(remote_address_condition.value.negate_condition, false)
          match_values     = try(remote_address_condition.value.match_values, [])
        }
      }

      dynamic "request_method_condition" {
        for_each = try(conditions.value.request_method_condition, [])
        content {
          match_values     = request_method_condition.value.match_values
          operator         = try(request_method_condition.value.operator, "Equal")
          negate_condition = try(request_method_condition.value.negate_condition, false)
        }
      }

      dynamic "query_string_condition" {
        for_each = try(conditions.value.query_string_condition, [])
        content {
          operator         = query_string_condition.value.operator
          negate_condition = try(query_string_condition.value.negate_condition, false)
          match_values     = try(query_string_condition.value.match_values, [])
          transforms       = try(query_string_condition.value.transforms, [])
        }
      }

      dynamic "post_args_condition" {
        for_each = try(conditions.value.post_args_condition, [])
        content {
          post_args_name   = post_args_condition.value.post_args_name
          operator         = post_args_condition.value.operator
          negate_condition = try(post_args_condition.value.negate_condition, false)
          match_values     = try(post_args_condition.value.match_values, [])
          transforms       = try(post_args_condition.value.transforms, [])
        }
      }

      dynamic "request_uri_condition" {
        for_each = try(conditions.value.request_uri_condition, [])
        content {
          operator         = request_uri_condition.value.operator
          negate_condition = try(request_uri_condition.value.negate_condition, false)
          match_values     = try(request_uri_condition.value.match_values, [])
          transforms       = try(request_uri_condition.value.transforms, [])
        }
      }

      dynamic "request_header_condition" {
        for_each = try(conditions.value.request_header_condition, [])
        content {
          header_name      = request_header_condition.value.header_name
          operator         = request_header_condition.value.operator
          negate_condition = try(request_header_condition.value.negate_condition, false)
          match_values     = try(request_header_condition.value.match_values, [])
          transforms       = try(request_header_condition.value.transforms, [])
        }
      }

      dynamic "request_body_condition" {
        for_each = try(conditions.value.request_body_condition, [])
        content {
          operator         = request_body_condition.value.operator
          match_values     = request_body_condition.value.match_values
          negate_condition = try(request_body_condition.value.negate_condition, false)
          transforms       = try(request_body_condition.value.transforms, [])
        }
      }

      dynamic "request_scheme_condition" {
        for_each = try(conditions.value.request_scheme_condition, [])
        content {
          operator         = try(request_scheme_condition.value.operator, "Equal")
          negate_condition = try(request_scheme_condition.value.negate_condition, false)
          match_values     = try(request_scheme_condition.value.match_values, [])
        }
      }

      dynamic "url_path_condition" {
        for_each = try(conditions.value.url_path_condition, [])
        content {
          operator         = url_path_condition.value.operator
          negate_condition = try(url_path_condition.value.negate_condition, false)
          match_values     = try(url_path_condition.value.match_values, [])
          transforms       = try(url_path_condition.value.transforms, [])
        }
      }

      dynamic "url_file_extension_condition" {
        for_each = try(conditions.value.url_file_extension_condition, [])
        content {
          operator         = url_file_extension_condition.value.operator
          negate_condition = try(url_file_extension_condition.value.negate_condition, false)
          match_values     = url_file_extension_condition.value.match_values
          transforms       = try(url_file_extension_condition.value.transforms, [])
        }
      }

      dynamic "url_filename_condition" {
        for_each = try(conditions.value.url_filename_condition, [])
        content {
          operator         = url_filename_condition.value.operator
          match_values     = try(url_filename_condition.value.match_values, [])
          negate_condition = try(url_filename_condition.value.negate_condition, false)
          transforms       = try(url_filename_condition.value.transforms, [])
        }
      }

      dynamic "http_version_condition" {
        for_each = try(conditions.value.http_version_condition, [])
        content {
          match_values     = http_version_condition.value.match_values
          operator         = try(http_version_condition.value.operator, "Equal")
          negate_condition = try(http_version_condition.value.negate_condition, false)
        }
      }

      dynamic "cookies_condition" {
        for_each = try(conditions.value.cookies_condition, [])
        content {
          cookie_name      = cookies_condition.value.cookie_name
          operator         = cookies_condition.value.operator
          negate_condition = try(cookies_condition.value.negate_condition, false)
          match_values     = try(cookies_condition.value.match_values, [])
          transforms       = try(cookies_condition.value.transforms, [])
        }
      }

      dynamic "is_device_condition" {
        for_each = try(conditions.value.is_device_condition, [])
        content {
          operator         = try(is_device_condition.value.operator, "Equal")
          negate_condition = try(is_device_condition.value.negate_condition, false)
          match_values     = try(is_device_condition.value.match_values, [])
        }
      }

      dynamic "socket_address_condition" {
        for_each = try(conditions.value.socket_address_condition, [])
        content {
          operator         = try(socket_address_condition.value.operator, "IPMatch")
          negate_condition = try(socket_address_condition.value.negate_condition, false)
          match_values     = try(socket_address_condition.value.match_values, [])
        }
      }

      dynamic "client_port_condition" {
        for_each = try(conditions.value.client_port_condition, [])
        content {
          operator         = client_port_condition.value.operator
          negate_condition = try(client_port_condition.value.negate_condition, false)
          match_values     = try(client_port_condition.value.match_values, [])
        }
      }

      dynamic "server_port_condition" {
        for_each = try(conditions.value.server_port_condition, [])
        content {
          operator         = server_port_condition.value.operator
          match_values     = server_port_condition.value.match_values
          negate_condition = try(server_port_condition.value.negate_condition, false)
        }
      }

      dynamic "host_name_condition" {
        for_each = try(conditions.value.host_name_condition, [])
        content {
          operator         = host_name_condition.value.operator
          match_values     = try(host_name_condition.value.match_values, [])
          transforms       = try(host_name_condition.value.transforms, [])
          negate_condition = try(host_name_condition.value.negate_condition, false)
        }
      }

      dynamic "ssl_protocol_condition" {
        for_each = try(conditions.value.ssl_protocol_condition, [])
        content {
          match_values     = ssl_protocol_condition.value.match_values
          operator         = try(ssl_protocol_condition.value.operator, "Equal")
          negate_condition = try(ssl_protocol_condition.value.negate_condition, false)
        }
      }
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
