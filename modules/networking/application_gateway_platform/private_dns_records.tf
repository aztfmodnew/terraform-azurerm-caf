
data "azurerm_private_dns_zone" "records" {
  for_each = {
    for key, value in try(var.settings.private_dns_records.a_records, {}) : key => value
    if try(value.private_dns_zone_id, null) == null && try(value.zone_name, null) != null
  }

  name = each.value.zone_name
  resource_group_name = try(
    each.value.resource_group_name,
    var.private_dns[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.private_dns_key].resource_group_name
  )
}

resource "azurerm_private_dns_a_record" "a_records" {
  for_each = try(var.settings.private_dns_records.a_records, {})

  name = each.value.name
  private_dns_zone_id = coalesce(
    try(each.value.private_dns_zone_id, null),
    try(data.azurerm_private_dns_zone.records[each.key].id, null),
    try(var.private_dns[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.private_dns_key].id, null)
  )
  ttl     = each.value.ttl
  records = [local.private_ip_address]
  tags    = merge(local.tags, try(each.value.tags, {}))
}
