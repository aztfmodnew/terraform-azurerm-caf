output "id" {
  value = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile.id
}

output "name" {
  value = azurecaf_name.cdn_frontdoor_profile.result
}

output "resource_guid" {
  value = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile.resource_guid
}

output "endpoints" {
  value = module.endpoints
}

output "origin_groups" {
  value = module.origin_groups
}

output "origins" {
  value = module.origins
}

output "rule_sets" {
  value = module.rule_sets
}

output "rules" {
  value = module.rules
}

output "secrets" {
  value = module.secrets
}

output "security_policies" {
  value = module.security_policies
}

output "routes" {
  value = module.routes
}

output "frontdoor_custom_domains" {
  value = module.frontdoor_custom_domains
}

output "firewall_policies" {
  value = module.firewall_policies
}

output "custom_domain_associations" {
  value = module.custom_domain_associations
}
