locals {
  api_management_name = coalesce(
    try(var.settings.api_management.name, null),
    try(var.remote_objects.api_management[coalesce(var.settings.api_management.lz_key, var.client_config.landingzone_key)][var.settings.api_management.key].name, null)
  )

  resource_group_name = coalesce(
    var.settings.resource_group_name,
    try(var.settings.resource_group.name, null),
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[coalesce(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][var.settings.resource_group.key].name, null)
  )

  product_id = coalesce(
    try(reverse(split("/", var.settings.product_id))[0], null),
    try(reverse(split("/", var.remote_objects.api_management_product[coalesce(var.settings.product.lz_key, var.client_config.landingzone_key)][var.settings.product.key].product_id))[0], null),
    try(reverse(split("/", var.remote_objects.api_management_product[coalesce(var.settings.product.lz_key, var.client_config.landingzone_key)][var.settings.product.key].id))[0], null)
  )
}
