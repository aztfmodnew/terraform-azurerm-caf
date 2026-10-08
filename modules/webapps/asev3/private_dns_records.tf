resource "azurerm_private_dns_a_record" "a_records" {
  depends_on = [azurerm_app_service_environment_v3.asev3]
  for_each   = try(var.settings.private_dns_records.a_records, {})

  name                = each.value.name == "" ? azurecaf_name.asev3.result : format("%s.%s", each.value.name, azurecaf_name.asev3.result)
  private_dns_zone_id = var.private_dns[coalesce(try(each.value.lz_key, null), var.client_config.landingzone_key)][each.value.private_dns_key].id
  ttl                 = each.value.ttl
  records             = azurerm_app_service_environment_v3.asev3.internal_inbound_ip_addresses
  tags                = merge(local.tags, try(each.value.tags, {}))
}
