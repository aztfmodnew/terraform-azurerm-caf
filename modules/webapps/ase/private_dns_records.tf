resource "azurerm_private_dns_a_record" "a_records" {
  depends_on = [azurerm_resource_group_template_deployment.ase]
  for_each   = try(var.settings.private_dns_records.a_records, {})

  name                = each.value.name == "" ? azurecaf_name.ase.result : format("%s.%s", each.value.name, azurecaf_name.ase.result)
  private_dns_zone_id = var.private_dns[coalesce(try(each.value.lz_key, null), var.client_config.landingzone_key)][each.value.private_dns_key].id
  ttl                 = each.value.ttl
  records             = data.azurerm_app_service_environment_v3.ase.internal_inbound_ip_addresses
  tags                = merge(try(each.value.tags, {}), local.tags)

  lifecycle {
    # TEMP until native tf provider for ASE ready to avoid force replacment of record on every ase changes
    ignore_changes = [records]
  }
}
