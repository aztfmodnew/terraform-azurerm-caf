output "endpoint_id" {
  value = azurerm_cdn_frontdoor_endpoint.endpoint.id
}

output "id" {
  value = azurerm_cdn_frontdoor_endpoint.endpoint.id
}

output "name" {
  value = azurecaf_name.endpoint.result
}

output "host_name" {
  value = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}
