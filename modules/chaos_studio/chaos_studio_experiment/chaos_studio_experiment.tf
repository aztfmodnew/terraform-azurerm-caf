resource "azurerm_chaos_studio_experiment" "experiment" {
  name                = azurecaf_name.experiment.result
  location            = local.location
  resource_group_name = local.resource_group_name

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = identity.value.type
      identity_ids = contains(["userassigned"], lower(identity.value.type)) ? local.managed_identities : null
    }
  }

  dynamic "selectors" {
    for_each = try(var.settings.selectors, [])

    content {
      name = selectors.value.name
      chaos_studio_target_ids = try(selectors.value.chaos_studio_target_ids, null) != null ? selectors.value.chaos_studio_target_ids : flatten([
        for target in try(selectors.value.chaos_studio_targets, []) : [
          coalesce(
            try(target.id, null),
            try(var.remote_objects.chaos_studio_targets[try(target.lz_key, var.client_config.landingzone_key)][target.key].id, null)
          )
        ]
      ])
    }
  }

  dynamic "steps" {
    for_each = try(var.settings.steps, [])

    content {
      name = steps.value.name

      dynamic "branch" {
        for_each = try(steps.value.branch, [])

        content {
          name = branch.value.name

          dynamic "actions" {
            for_each = try(branch.value.actions, [])

            content {
              action_type   = actions.value.action_type
              duration      = try(actions.value.duration, null)
              parameters    = try(actions.value.parameters, null)
              selector_name = try(actions.value.selector_name, null)
              urn = try(actions.value.urn, null) != null ? actions.value.urn : try(
                var.remote_objects.chaos_studio_capabilities[try(actions.value.capability.lz_key, var.client_config.landingzone_key)][actions.value.capability.key].urn,
                null
              )
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
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}
