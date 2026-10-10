output "ids" {
  value = azapi_resource.vnet_links.*
}

output "links" {
  value       = azapi_resource.vnet_links
  description = "Private DNS virtual network links indexed by configuration key."
}