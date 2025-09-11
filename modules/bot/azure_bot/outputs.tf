output "id" {
  description = "The ID of the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.id
}

output "name" {
  description = "The CAF-compliant name of the Azure Bot Service"
  value       = azurecaf_name.bot_service.result
}

output "microsoft_app_id" {
  description = "The Microsoft Application ID for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.microsoft_app_id
}

output "sku" {
  description = "The SKU of the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.sku
}

output "endpoint" {
  description = "The Azure Bot Service endpoint"
  value       = azurerm_bot_service_azure_bot.bot_service.endpoint
}

output "display_name" {
  description = "The display name of the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.display_name
}

output "icon_url" {
  description = "The Icon URL of the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.icon_url
}

output "microsoft_app_type" {
  description = "The Microsoft App Type for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.microsoft_app_type
}

output "microsoft_app_tenant_id" {
  description = "The Microsoft App Tenant ID for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.microsoft_app_tenant_id
}

output "microsoft_app_msi_id" {
  description = "The Microsoft App Managed Service Identity ID for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.microsoft_app_msi_id
}

output "local_authentication_enabled" {
  description = "Whether local authentication is enabled for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.local_authentication_enabled
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.public_network_access_enabled
}

output "streaming_endpoint_enabled" {
  description = "Whether streaming endpoint is enabled for the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.streaming_endpoint_enabled
}

output "luis_app_ids" {
  description = "The list of LUIS App IDs associated with the Azure Bot Service"
  value       = azurerm_bot_service_azure_bot.bot_service.luis_app_ids
}

output "resource_group_name" {
  description = "The name of the resource group where the Azure Bot Service is created"
  value       = azurerm_bot_service_azure_bot.bot_service.resource_group_name
}

output "location" {
  description = "The Azure location where the Azure Bot Service is deployed"
  value       = azurerm_bot_service_azure_bot.bot_service.location
}

output "ms_teams_channels" {
  description = "The MS Teams channels associated with the Azure Bot Service"
  value       = module.ms_teams_channels
}
