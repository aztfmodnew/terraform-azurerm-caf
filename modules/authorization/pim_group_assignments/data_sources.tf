locals {
  group_data_lookup = (
    try(local.group_selector.key, null) == null &&
    try(local.group_selector.display_name, null) != null
    ) ? {
    this = local.group_selector
  } : {}

  principal_group_data_lookup = (
    try(local.principal_group_selector.key, null) == null &&
    try(local.principal_group_selector.display_name, null) != null
    ) ? {
    this = local.principal_group_selector
  } : {}

  principal_user_data_lookup = (
    try(local.principal_user_selector.key, null) == null &&
    try(local.principal_user_selector.user_principal_name, null) != null
    ) ? {
    this = local.principal_user_selector
  } : {}
}

data "azuread_group" "group" {
  for_each = local.group_data_lookup

  display_name = each.value.display_name
}

data "azuread_group" "principal_group" {
  for_each = local.principal_group_data_lookup

  display_name = each.value.display_name
}

data "azuread_user" "principal_user" {
  for_each = local.principal_user_data_lookup

  user_principal_name = each.value.user_principal_name
}

locals {
  group_id_from_data           = try(data.azuread_group.group["this"].object_id, null)
  principal_group_id_from_data = try(data.azuread_group.principal_group["this"].object_id, null)
  principal_user_id_from_data  = try(data.azuread_user.principal_user["this"].object_id, null)
}
