module "ms_teams_channels" {
  source   = "./ms_teams_channel"
  for_each = try(var.settings.ms_teams_channels, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = local.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    azure_bot = azurerm_bot_service_azure_bot.bot_service
  })

  depends_on = [azurerm_bot_service_azure_bot.bot_service]
}
