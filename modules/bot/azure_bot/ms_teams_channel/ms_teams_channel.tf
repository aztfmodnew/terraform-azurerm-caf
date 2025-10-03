resource "azurerm_bot_channel_ms_teams" "ms_teams_channel" {
  bot_name = coalesce(
    try(var.settings.bot_name, null),
    try(var.remote_objects.azure_bot.name, null),
    try(var.remote_objects.azure_bots[try(var.settings.azure_bot.lz_key, var.client_config.landingzone_key)][var.settings.azure_bot.key].name, null)
  )
  resource_group_name = local.resource_group_name
  location            = local.location

  # Optional arguments
  calling_web_hook       = try(var.settings.calling_web_hook, null)
  deployment_environment = try(var.settings.deployment_environment, "CommercialDeployment")
  enable_calling         = try(var.settings.enable_calling, false)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, "30m")
      update = try(timeouts.value.update, "30m")
      read   = try(timeouts.value.read, "5m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
