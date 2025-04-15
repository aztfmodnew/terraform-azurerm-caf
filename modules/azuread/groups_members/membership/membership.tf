resource "azuread_group_member" "group_ids" {
  for_each = length(var.azuread_groups) > 0 && length(try(var.members.keys, [])) > 0 ? toset(try(var.members.keys, [])) : []

  group_object_id  = var.group_object_id
  member_object_id = var.azuread_groups[each.key].object_id
}

resource "azuread_group_member" "ids" {
  for_each = length(var.azuread_service_principals) > 0 && length(try(var.members.keys, [])) > 0 ? toset(try(var.members.keys, [])) : []

  group_object_id  = var.group_object_id
  member_object_id = var.azuread_service_principals[each.key].object_id
}

resource "azuread_group_member" "msi_ids" {
  for_each = length(var.managed_identities) > 0 && length(try(var.members.keys, [])) > 0 ? toset(try(var.members.keys, [])) : []

  group_object_id  = var.group_object_id
  member_object_id = var.managed_identities[each.key].principal_id
}

resource "azuread_group_member" "mssql_server_ids" {
  for_each = length(var.mssql_servers) > 0 && length(try(var.members.keys, [])) > 0 ? toset(try(var.members.keys, [])) : []

  group_object_id  = var.group_object_id
  member_object_id = var.mssql_servers[each.key].rbac_id
}