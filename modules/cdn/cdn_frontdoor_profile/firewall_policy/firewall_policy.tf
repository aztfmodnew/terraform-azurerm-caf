resource "azurerm_cdn_frontdoor_firewall_policy" "firewall_policy" {
  name                = azurecaf_name.firewall_policy.result
  resource_group_name = local.resource_group_name
  sku_name = coalesce(
    try(var.settings.sku_name, null),
    try(var.remote_objects.cdn_frontdoor_profile.sku_name, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].sku_name, null)
  )

  enabled                           = try(var.settings.enabled, true)
  mode                              = var.settings.mode
  request_body_check_enabled        = try(var.settings.request_body_check_enabled, true)
  redirect_url                      = try(var.settings.redirect_url, null)
  custom_block_response_status_code = try(var.settings.custom_block_response_status_code, null)
  custom_block_response_body        = try(var.settings.custom_block_response_body, null)

  dynamic "custom_rule" {
    for_each = try(var.settings.custom_rules, {})

    content {
      name                           = custom_rule.value.name
      enabled                        = try(custom_rule.value.enabled, true)
      priority                       = try(custom_rule.value.priority, 1)
      rate_limit_duration_in_minutes = try(custom_rule.value.rate_limit_duration_in_minutes, 1)
      rate_limit_threshold           = try(custom_rule.value.rate_limit_threshold, 10)
      type                           = custom_rule.value.type
      action                         = custom_rule.value.action

      dynamic "match_condition" {
        for_each = try(custom_rule.value.match_conditions, [])

        content {
          match_variable     = match_condition.value.match_variable
          operator           = match_condition.value.operator
          negation_condition = try(match_condition.value.negation_condition, false)
          match_values       = match_condition.value.match_values
          selector           = try(match_condition.value.selector, null)
          transforms         = try(match_condition.value.transforms, null)
        }
      }
    }
  }

  dynamic "managed_rule" {
    for_each = try(var.settings.managed_rules, [])

    content {
      type    = managed_rule.value.type
      version = managed_rule.value.version
      action  = managed_rule.value.action

      dynamic "exclusion" {
        for_each = try(managed_rule.value.exclusions, [])

        content {
          match_variable = exclusion.value.match_variable
          operator       = exclusion.value.operator
          selector       = exclusion.value.selector
        }
      }

      dynamic "override" {
        for_each = try(managed_rule.value.overrides, [])

        content {
          rule_group_name = override.value.rule_group_name

          dynamic "exclusion" {
            for_each = try(override.value.exclusions, [])

            content {
              match_variable = exclusion.value.match_variable
              operator       = exclusion.value.operator
              selector       = exclusion.value.selector
            }
          }

          dynamic "rule" {
            for_each = try(override.value.rules, [])

            content {
              rule_id = rule.value.rule_id
              enabled = try(rule.value.enabled, false)
              action  = rule.value.action

              dynamic "exclusion" {
                for_each = try(rule.value.exclusions, [])

                content {
                  match_variable = exclusion.value.match_variable
                  operator       = exclusion.value.operator
                  selector       = exclusion.value.selector
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  tags = local.tags
}
