locals {
  local_api_operation = try(
    var.remote_objects.api_management_api_operation[var.client_config.landingzone_key][var.settings.api_operation.key],
    null
  )
  referenced_api_operation = try(
    var.remote_objects.api_management_api_operation[coalesce(
      try(var.settings.api_operation.lz_key, null),
      var.client_config.landingzone_key
    )][var.settings.api_operation.key],
    null
  )
  operation_id = try(coalesce(
    try(local.local_api_operation.operation_id, null),
    try(regex("/operations/([^/]+)$", local.local_api_operation.id)[0], null),
    try(local.local_api_operation.id, null),
    try(local.referenced_api_operation.operation_id, null),
    try(regex("/operations/([^/]+)$", local.referenced_api_operation.id)[0], null),
    try(local.referenced_api_operation.id, null),
    try(var.settings.api_operation.id, null)
  ), null)
}

resource "azurerm_api_management_api_operation_policy" "apim" {
  api_name            = var.api_name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
  operation_id        = local.operation_id
  xml_content         = try(var.settings.xml_content, null)
  xml_link            = try(var.settings.xml_link, null)

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