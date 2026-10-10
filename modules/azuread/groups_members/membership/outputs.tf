output "memberships" {
  description = "Membership resources by source collection."
  value = {
    groups             = azuread_group_member.group_ids
    service_principals = azuread_group_member.ids
    managed_identities = azuread_group_member.msi_ids
    mssql_servers      = azuread_group_member.mssql_server_ids
  }
}
