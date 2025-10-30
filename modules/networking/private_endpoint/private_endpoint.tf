
resource "azurecaf_name" "pep" {
  name          = var.name
  resource_type = "azurerm_private_endpoint"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}

resource "azurerm_private_endpoint" "pep" {
  name                          = azurecaf_name.pep.result
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = try(var.settings.custom_network_interface_name, null)
  tags                          = local.tags

  private_service_connection {
    name                              = var.settings.private_service_connection.name
    private_connection_resource_id    = try(var.settings.private_service_connection.private_connection_resource_id, var.resource_id)
    private_connection_resource_alias = try(var.settings.private_service_connection.private_connection_resource_alias, null)
    is_manual_connection              = try(var.settings.private_service_connection.is_manual_connection, false)
    subresource_names                 = try(var.settings.private_service_connection.subresource_names, null)
    request_message                   = try(var.settings.private_service_connection.request_message, null)
  }

  dynamic "private_dns_zone_group" {
    for_each = can(var.settings.private_dns) ? [var.settings.private_dns] : []

    content {
      name = lookup(private_dns_zone_group.value, "zone_group_name", "default")
      private_dns_zone_ids = concat(
        flatten([
          for key in try(private_dns_zone_group.value.keys, []) : [
            try(var.private_dns[try(private_dns_zone_group.value.lz_key, var.client_config.landingzone_key)][key].id, [])
          ]
          ]
        ),
        lookup(private_dns_zone_group.value, "ids", [])
      )

    }
  }

  dynamic "ip_configuration" {
    for_each = try(var.settings.ip_configurations, {})

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = lookup(ip_configuration.value, "subresource_name", null)
      member_name        = lookup(ip_configuration.value, "member_name", null)
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
}

resource "time_sleep" "delay" {
  count           = try(var.settings.delay_time_after_creation, null) != null ? 1 : 0
  depends_on      = [azurerm_private_endpoint.pep]
  create_duration = var.settings.delay_time_after_creation

  lifecycle {
    replace_triggered_by = [azurerm_private_endpoint.pep]
  }
}