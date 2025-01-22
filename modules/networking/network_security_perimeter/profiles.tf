resource "azapi_resource" "profiles" {
  for_each  = try(var.settings.profiles, {})
  type      = "Microsoft.Network/networkSecurityPerimeters/profiles@2023-08-01-preview"
  name      = each.value.name
  location  = coalesce(try(each.value.location, null), var.resource_group.location)
  parent_id = azapi_resource.networkSecurityPerimeter.id
  body = {
    properties = {
    }
  }
  tags = merge(local.tags, try(each.value.tags, null))
}

resource "azapi_resource" "accessRules" {
  # It can be empty if there are no access rules
  for_each  = try(var.settings.access_rules, {})
  type      = "Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2023-08-01-preview"
  name      = each.value.name
  parent_id = coalesce(try(each.value.profile_id, null), azapi_resource.profiles[each.value.profile_key].id)
  location  = coalesce(try(each.value.location, null), var.resource_group.location)
  body = {
    properties = {
      addressPrefixes           = try(each.value.address_prefixes, null)
      direction                 = try(each.value.direction, null)
      emailAddresses            = try(each.value.email_addresses, null)
      fullyQualifiedDomainNames = try(each.value.fully_qualified_domain_names, null)
      phoneNumbers              = try(each.value.phone_numbers, null)
      serviceTags               = try(each.value.service_tags, null)
      subscriptions             = try(each.value.subscriptions, null)
    }
  }
  tags = merge(local.tags, try(each.value.tags, null))
}