# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/notification_hub_namespace

resource "azurerm_notification_hub_namespace" "notification_hub_namespace" {
  name                    = var.settings.name
  resource_group_name     = local.resource_group_name
  location                = local.location
  namespace_type          = var.settings.namespace_type
  sku_name                = var.settings.sku_name
  enabled                 = try(var.settings.enabled, null)
  zone_redundancy_enabled = try(var.settings.zone_redundancy_enabled, null)
  replication_region      = try(var.settings.replication_region, null)
  tags                    = merge(local.base_tags, try(var.settings.tags, {}))
}
