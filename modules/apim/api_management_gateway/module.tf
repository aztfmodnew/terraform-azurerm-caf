resource "azurecaf_name" "apim" {
  name          = var.settings.name
  resource_type = "azurerm_api_management_gateway"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_api_management_gateway" "apim" {
  name = azurecaf_name.apim.result

  api_management_id = coalesce(
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].id, null),
    try(var.remote_objects.api_management[var.client_config.landingzone_key][var.settings.api_management.key].id, null),
    try(var.settings.api_management.id, null)
  )

  description = try(var.settings.description, null)

  dynamic "location_data" {
    for_each = [var.settings.location_data]

    content {
      name     = location_data.value.name
      city     = try(location_data.value.city, null)
      district = try(location_data.value.district, null)
      region   = try(location_data.value.region, null)
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
