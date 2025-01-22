resource "azurerm_network_manager_admin_rule" "admin_rule" {
  name = var.settings.name
  admin_rule_collection_id = coalesce(
    try(var.settings.admin_rule_collection_id, null),
    try(var.remote_objects.admin_rule_collections[var.settings.admin_rule_collection.key].id, null),
    try(var.remote_objects.admin_rule_collections[try(var.settings.admin_rule_collection.lz_key, var.client_config.landingzone_key)][var.settings.admin_rule_collection.key].id, null)
  )
  action                  = var.settings.action
  direction               = var.settings.direction
  priority                = var.settings.priority
  protocol                = var.settings.protocol
  description             = try(var.settings.description, null)
  destination_port_ranges = try(var.settings.destination_port_ranges, null)

  dynamic "destination" {
    for_each = try(var.settings.destination, null) != null ? var.settings.destination : []
    content {
      address_prefix      = destination.value.address_prefix
      address_prefix_type = destination.value.address_prefix_type
    }
  }

  source_port_ranges = try(var.settings.source_port_ranges, null)

  dynamic "source" {
    for_each = try(var.settings.source, null) != null ? var.settings.source : []
    content {
      address_prefix      = source.value.address_prefix
      address_prefix_type = source.value.address_prefix_type
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) != null ? [var.settings.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
