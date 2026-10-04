locals {
  condition_operator_defaults = {
    remote_address           = "IPMatch"
    remote_address_condition = "IPMatch"
    socket_address           = "IPMatch"
    socket_address_condition = "IPMatch"
    request_method           = "Equal"
    request_method_condition = "Equal"
    request_scheme           = "Equal"
    request_scheme_condition = "Equal"
    http_version             = "Equal"
    http_version_condition   = "Equal"
    device_type              = "Equal"
    is_device_condition      = "Equal"
    ssl_protocol             = "Equal"
    ssl_protocol_condition   = "Equal"
  }

  # AzureRM 5.8 encodes legacy negate_condition in the operator itself.
  rule_conditions = [
    for group in try(var.settings.conditions, []) : {
      for name, entries in group : name => [
        for condition in entries : merge(condition, {
          operator = try(condition.negate_condition, false) ? (
            startswith(try(condition.operator, local.condition_operator_defaults[name]), "Not") ?
            trimprefix(try(condition.operator, local.condition_operator_defaults[name]), "Not") :
            "Not${try(condition.operator, local.condition_operator_defaults[name])}"
          ) : try(condition.operator, local.condition_operator_defaults[name])
          values = contains(["Any", "NotAny"], try(condition.operator, "")) ? null : try(condition.values, condition.match_values, null)
        })
      ]
    }
  ]
}

resource "azurerm_cdn_frontdoor_rule" "rule" {
  name = azurecaf_name.rule.result
  cdn_frontdoor_rule_set_id = coalesce(
    try(var.settings.cdn_frontdoor_rule_set_id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[var.settings.rule_set_key].id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[try(var.settings.rule_set.lz_key, var.client_config.landingzone_key)][var.settings.rule_set.key].id, null)
  )
  order              = var.settings.order
  behaviour_on_match = try(var.settings.behaviour_on_match, var.settings.behavior_on_match, "Continue")

  dynamic "actions" {
    for_each = var.settings.actions
    content {
      dynamic "url_rewrite" {
        for_each = try(actions.value.url_rewrite, actions.value.url_rewrite_action, null) == null ? [] : [try(actions.value.url_rewrite, actions.value.url_rewrite_action)]
        content {
          destination_path                = try(url_rewrite.value.destination_path, url_rewrite.value.destination)
          source_pattern                  = url_rewrite.value.source_pattern
          preserve_unmatched_path_enabled = try(url_rewrite.value.preserve_unmatched_path_enabled, url_rewrite.value.preserve_unmatched_path, false)
        }
      }

      dynamic "url_redirect" {
        for_each = try(actions.value.url_redirect, actions.value.url_redirect_action, null) == null ? [] : [try(actions.value.url_redirect, actions.value.url_redirect_action)]
        content {
          redirect_type         = url_redirect.value.redirect_type
          destination_host_name = try(url_redirect.value.destination_host_name, url_redirect.value.destination_hostname, null)
          redirect_protocol     = try(url_redirect.value.redirect_protocol, "MatchRequest")
          destination_path      = try(url_redirect.value.destination_path, null)
          query_string          = try(url_redirect.value.query_string, null)
          destination_fragment  = try(url_redirect.value.destination_fragment, null)
        }
      }

      dynamic "route_configuration_override" {
        for_each = try(actions.value.route_configuration_override, actions.value.route_configuration_override_action, null) == null ? [] : [try(actions.value.route_configuration_override, actions.value.route_configuration_override_action)]
        content {
          caching {
            behaviour               = try(route_configuration_override.value.caching.behaviour, route_configuration_override.value.cache_behavior, "HonorOrigin")
            duration                = try(route_configuration_override.value.caching.duration, route_configuration_override.value.cache_duration, null)
            compression_enabled     = try(route_configuration_override.value.caching.compression_enabled, route_configuration_override.value.compression_enabled, null)
            query_string_behaviour  = try(route_configuration_override.value.caching.query_string_behaviour, route_configuration_override.value.query_string_caching_behavior, try(route_configuration_override.value.caching.behaviour, route_configuration_override.value.cache_behavior, "HonorOrigin") == "Disabled" ? null : "IgnoreQueryString")
            query_string_parameters = try(route_configuration_override.value.caching.query_string_parameters, route_configuration_override.value.query_string_parameters, null)
          }

          dynamic "origin_group" {
            for_each = try(route_configuration_override.value.origin_group, null) != null || can(route_configuration_override.value.origin_group_key) || try(route_configuration_override.value.cdn_frontdoor_origin_group_id, null) != null ? [route_configuration_override.value] : []
            content {
              cdn_frontdoor_origin_group_id = coalesce(
                try(origin_group.value.origin_group.cdn_frontdoor_origin_group_id, null),
                try(origin_group.value.cdn_frontdoor_origin_group_id, null),
                try(var.remote_objects.cdn_frontdoor_origin_groups[origin_group.value.origin_group_key].id, null),
                try(var.remote_objects.cdn_frontdoor_origin_groups[try(origin_group.value.origin_group.lz_key, var.client_config.landingzone_key)][origin_group.value.origin_group.key].id, null)
              )
              forwarding_protocol = coalesce(try(origin_group.value.origin_group.forwarding_protocol, origin_group.value.forwarding_protocol, null), "MatchRequest")
            }
          }
        }
      }

      dynamic "modify_request_header" {
        for_each = try(actions.value.modify_request_header, actions.value.request_header_action, [])
        content {
          operator     = try(modify_request_header.value.operator, modify_request_header.value.header_action)
          header_name  = modify_request_header.value.header_name
          header_value = try(modify_request_header.value.header_value, modify_request_header.value.value, null)
        }
      }

      dynamic "modify_response_header" {
        for_each = try(actions.value.modify_response_header, actions.value.response_header_action, [])
        content {
          operator     = try(modify_response_header.value.operator, modify_response_header.value.header_action)
          header_name  = modify_response_header.value.header_name
          header_value = try(modify_response_header.value.header_value, modify_response_header.value.value, null)
        }
      }
    }
  }

  dynamic "conditions" {
    for_each = local.rule_conditions
    content {
      dynamic "remote_address" {
        for_each = try(conditions.value.remote_address, conditions.value.remote_address_condition, [])
        content {
          operator = remote_address.value.operator
          values   = remote_address.value.values
        }
      }
      dynamic "request_method" {
        for_each = try(conditions.value.request_method, conditions.value.request_method_condition, [])
        content {
          operator = request_method.value.operator
          values   = request_method.value.values
        }
      }
      dynamic "query_string" {
        for_each = try(conditions.value.query_string, conditions.value.query_string_condition, [])
        content {
          operator   = query_string.value.operator
          values     = query_string.value.values
          transforms = try(query_string.value.transforms, [])
        }
      }
      dynamic "post_argument" {
        for_each = try(conditions.value.post_argument, conditions.value.post_args_condition, [])
        content {
          name       = try(post_argument.value.name, post_argument.value.post_args_name)
          operator   = post_argument.value.operator
          values     = post_argument.value.values
          transforms = try(post_argument.value.transforms, [])
        }
      }
      dynamic "request_url" {
        for_each = try(conditions.value.request_url, conditions.value.request_uri_condition, [])
        content {
          operator   = request_url.value.operator
          values     = request_url.value.values
          transforms = try(request_url.value.transforms, [])
        }
      }
      dynamic "request_header" {
        for_each = try(conditions.value.request_header, conditions.value.request_header_condition, [])
        content {
          name       = try(request_header.value.name, request_header.value.header_name)
          operator   = request_header.value.operator
          values     = request_header.value.values
          transforms = try(request_header.value.transforms, [])
        }
      }
      dynamic "request_body" {
        for_each = try(conditions.value.request_body, conditions.value.request_body_condition, [])
        content {
          operator   = request_body.value.operator
          values     = request_body.value.values
          transforms = try(request_body.value.transforms, [])
        }
      }
      dynamic "request_scheme" {
        for_each = try(conditions.value.request_scheme, conditions.value.request_scheme_condition, [])
        content {
          operator = request_scheme.value.operator
          values   = request_scheme.value.values
        }
      }
      dynamic "request_path" {
        for_each = try(conditions.value.request_path, conditions.value.url_path_condition, [])
        content {
          operator   = request_path.value.operator
          values     = request_path.value.values
          transforms = try(request_path.value.transforms, [])
        }
      }
      dynamic "request_file_extension" {
        for_each = try(conditions.value.request_file_extension, conditions.value.url_file_extension_condition, [])
        content {
          operator   = request_file_extension.value.operator
          values     = request_file_extension.value.values
          transforms = try(request_file_extension.value.transforms, [])
        }
      }
      dynamic "request_filename" {
        for_each = try(conditions.value.request_filename, conditions.value.url_filename_condition, [])
        content {
          operator   = request_filename.value.operator
          values     = request_filename.value.values
          transforms = try(request_filename.value.transforms, [])
        }
      }
      dynamic "http_version" {
        for_each = try(conditions.value.http_version, conditions.value.http_version_condition, [])
        content {
          operator = http_version.value.operator
          values   = http_version.value.values
        }
      }
      dynamic "request_cookies" {
        for_each = try(conditions.value.request_cookies, conditions.value.cookies_condition, [])
        content {
          name       = try(request_cookies.value.name, request_cookies.value.cookie_name)
          operator   = request_cookies.value.operator
          values     = request_cookies.value.values
          transforms = try(request_cookies.value.transforms, [])
        }
      }
      dynamic "device_type" {
        for_each = try(conditions.value.device_type, conditions.value.is_device_condition, [])
        content {
          operator = device_type.value.operator
          values   = device_type.value.values
        }
      }
      dynamic "socket_address" {
        for_each = try(conditions.value.socket_address, conditions.value.socket_address_condition, [])
        content {
          operator = socket_address.value.operator
          values   = socket_address.value.values
        }
      }
      dynamic "client_port" {
        for_each = try(conditions.value.client_port, conditions.value.client_port_condition, [])
        content {
          operator = client_port.value.operator
          values   = client_port.value.values
        }
      }
      dynamic "server_port" {
        for_each = try(conditions.value.server_port, conditions.value.server_port_condition, [])
        content {
          operator = server_port.value.operator
          values   = server_port.value.values
        }
      }
      dynamic "host_name" {
        for_each = try(conditions.value.host_name, conditions.value.host_name_condition, [])
        content {
          operator   = host_name.value.operator
          values     = host_name.value.values
          transforms = try(host_name.value.transforms, [])
        }
      }
      dynamic "ssl_protocol" {
        for_each = try(conditions.value.ssl_protocol, conditions.value.ssl_protocol_condition, [])
        content {
          operator = ssl_protocol.value.operator
          values   = ssl_protocol.value.values
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
