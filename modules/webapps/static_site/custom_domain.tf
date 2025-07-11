resource "azurerm_static_web_app_custom_domain" "custom_domains" {
  for_each = var.custom_domains

  static_web_app_id   = azurerm_static_web_app.static_site.id
  domain_name         = each.value.domain_name
  validation_type     = each.value.validation_type
}
