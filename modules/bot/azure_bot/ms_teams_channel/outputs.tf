output "id" {
  value       = azurerm_bot_channel_ms_teams.ms_teams_channel.id
  description = "The ID of the MS Teams channel integration"
}

output "bot_name" {
  value       = azurerm_bot_channel_ms_teams.ms_teams_channel.bot_name
  description = "The name of the bot associated with the MS Teams channel"
}

output "calling_web_hook" {
  value       = azurerm_bot_channel_ms_teams.ms_teams_channel.calling_web_hook
  description = "The webhook for Microsoft Teams channel calls"
}

output "deployment_environment" {
  value       = azurerm_bot_channel_ms_teams.ms_teams_channel.deployment_environment
  description = "The deployment environment for Microsoft Teams channel calls"
}

output "enable_calling" {
  value       = azurerm_bot_channel_ms_teams.ms_teams_channel.enable_calling
  description = "Whether Microsoft Teams channel calls are enabled"
}
