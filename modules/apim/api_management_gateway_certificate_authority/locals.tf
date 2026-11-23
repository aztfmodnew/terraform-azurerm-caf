locals {
  api_management_id = coalesce(
    try(var.settings.api_management_id, null),
    try(var.settings.api_management.id, null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].id, null)
  )
  certificate_name = coalesce(
    try(var.settings.certificate_name, null),
    try(var.settings.certificate.name, null),
    try(reverse(split("/", var.settings.certificate.id))[0], null),
    try(var.remote_objects.api_management_certificate[coalesce(try(var.settings.certificate.lz_key, null), var.client_config.landingzone_key)][var.settings.certificate.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management_certificate[coalesce(try(var.settings.certificate.lz_key, null), var.client_config.landingzone_key)][var.settings.certificate.key].id))[0], null)
  )
  gateway_name = coalesce(
    try(var.settings.gateway_name, null),
    try(var.settings.gateway.name, null),
    try(reverse(split("/", var.settings.gateway.id))[0], null),
    try(var.remote_objects.api_management_gateway[coalesce(try(var.settings.gateway.lz_key, null), var.client_config.landingzone_key)][var.settings.gateway.key].name, null),
    try(reverse(split("/", var.remote_objects.api_management_gateway[coalesce(try(var.settings.gateway.lz_key, null), var.client_config.landingzone_key)][var.settings.gateway.key].id))[0], null)
  )
}
