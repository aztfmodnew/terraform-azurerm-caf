resource "azapi_resource" "profiles" {
  for_each  = try(var.settings.profiles, {})
  type      = "Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01"
  name      = each.value.name
  parent_id = azapi_resource.networkSecurityPerimeter.id
  body = {
    properties = {
    }
  }
  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azapi_resource" "accessRules" {
  # It can be empty if there are no access rules
  for_each             = try(var.settings.access_rules, {})
  type                 = "Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-07-01"
  name                 = each.value.name
  parent_id            = coalesce(try(each.value.profile_id, null), try(azapi_resource.profiles[each.value.profile_key].id, null))
  ignore_null_property = true
  body = {
    properties = {
      addressPrefixes           = try(each.value.address_prefixes, null)
      direction                 = each.value.direction
      emailAddresses            = try(each.value.email_addresses, null)
      fullyQualifiedDomainNames = try(each.value.fully_qualified_domain_names, null)
      phoneNumbers              = try(each.value.phone_numbers, null)
      serviceTags               = try(each.value.service_tags, null)
      subscriptions             = try(each.value.subscriptions, null)
    }
  }
  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}