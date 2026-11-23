locals {
  product_id = coalesce(
    try(var.settings.product_id, null),
    try(var.settings.product.product_id, null),
    try(var.settings.product.name, null),
    try(reverse(split("/", var.settings.product.id))[0], null),
    try(var.remote_objects.api_management_product[coalesce(try(var.settings.product.lz_key, null), var.client_config.landingzone_key)][var.settings.product.key].product_id, null),
    try(reverse(split("/", var.remote_objects.api_management_product[coalesce(try(var.settings.product.lz_key, null), var.client_config.landingzone_key)][var.settings.product.key].id))[0], null)
  )
  group_name = coalesce(
    try(var.settings.group_name, null),
    try(var.settings.group.name, null),
    try(reverse(split("/", var.settings.group.id))[0], null),
    try(var.remote_objects.api_management_group[coalesce(try(var.settings.group.lz_key, null), var.client_config.landingzone_key)][var.settings.group.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management_group[coalesce(try(var.settings.group.lz_key, null), var.client_config.landingzone_key)][var.settings.group.key].id))[0], null)
  )
  api_management_name = coalesce(
    try(var.settings.api_management_name, null),
    try(var.settings.api_management.name, null),
    try(reverse(split("/", var.settings.api_management.id))[0], null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].id))[0], null)
  )
  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(reverse(split("/", var.settings.resource_group.id))[0], null),
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)][var.settings.resource_group.key].name, null)
  )
}
