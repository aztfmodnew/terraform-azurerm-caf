resource "azurerm_palo_alto_local_rulestack" "rulestack" {
  name                = var.settings.name
  resource_group_name = local.resource_group_name
  location            = local.location

  description                       = try(var.settings.description, null)
  anti_spyware_profile              = try(var.settings.anti_spyware_profile, null)
  anti_virus_profile                = try(var.settings.anti_virus_profile, null)
  dns_subscription                  = try(var.settings.dns_subscription_enabled, null)
  file_blocking_profile             = try(var.settings.file_blocking_profile, null)
  min_app_id_version                = try(var.settings.min_app_id_version, null)
  outbound_trust_certificate_name   = try(var.settings.outbound_trust_certificate_name, null)
  outbound_untrust_certificate_name = try(var.settings.outbound_untrust_certificate_name, null)
  url_filtering_profile             = try(var.settings.url_filtering_profile, null)
  vulnerability_protection_profile  = try(var.settings.vulnerability_protection_profile, null)

  tags = local.tags
}
