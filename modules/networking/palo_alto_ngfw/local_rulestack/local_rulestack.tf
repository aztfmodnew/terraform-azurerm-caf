resource "azurerm_palo_alto_local_rulestack" "rulestack" {
  name                = var.settings.name
  resource_group_name = local.resource_group_name
  location            = local.location

  description           = try(var.settings.description, null)
  anti_spyware_profile  = try(var.settings.anti_spyware_profile, null)
  anti_virus_profile    = try(var.settings.anti_virus_profile, null)
  dns_subscription      = try(var.settings.dns_subscription_enabled, null)
  file_blocking_profile = try(var.settings.file_blocking_profile, null)
  # Removed unsupported argument: min_app_id_version
  # Removed unsupported argument: outbound_trust_certificate_name
  # Removed unsupported argument: outbound_untrust_certificate_name
  url_filtering_profile = try(var.settings.url_filtering_profile, null)
  # Removed unsupported argument: vulnerability_protection_profile

  # Removed unsupported argument: tags
}
