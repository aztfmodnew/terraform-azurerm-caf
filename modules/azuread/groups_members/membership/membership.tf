resource "azuread_group_member" "group_ids" {
  for_each = var.azuread_groups != {} && can(var.members.keys) ? { for k, v in var.members : k => v if contains(keys(var.azuread_groups), k) } : {}

  group_object_id  = var.group_object_id
  member_object_id = var.azuread_groups[each.key].object_id
}

resource "azuread_group_member" "ids" {
  for_each = var.azuread_service_principals != {} && can(var.members.keys) ? { for k, v in var.members : k => v if contains(keys(var.azuread_service_principals), k) } : {}

  group_object_id  = var.group_object_id
  member_object_id = var.azuread_service_principals[each.key].object_id
}

resource "azuread_group_member" "msi_ids" {
  for_each = var.managed_identities != {} && can(var.members.keys) ? { for k, v in var.members : k => v if contains(keys(var.managed_identities), k) } : {}

  group_object_id  = var.group_object_id
  member_object_id = var.managed_identities[each.key].principal_id
}

resource "azuread_group_member" "mssql_server_ids" {
  for_each = var.mssql_servers != {} && can(var.members.keys) ? { for k, v in var.members : k => v if contains(keys(var.mssql_servers), k) } : {}

  group_object_id  = var.group_object_id
  member_object_id = var.mssql_servers[each.key].rbac_id
}