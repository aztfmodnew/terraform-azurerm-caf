mock_provider "azuread" {}

run "single_membership_passes_ids_and_timeouts" {
  command = plan
  module {
    source = "../modules/azuread/groups_members/member"
  }
  variables {
    group_object_id  = "00000000-0000-0000-0000-000000000001"
    member_object_id = "00000000-0000-0000-0000-000000000002"
    timeouts         = { create = "10m", read = "6m", delete = "10m" }
  }
  assert {
    condition = (
      azuread_group_member.id.group_object_id == var.group_object_id &&
      azuread_group_member.id.member_object_id == var.member_object_id &&
      azuread_group_member.id.timeouts.create == "10m" &&
      azuread_group_member.id.timeouts.read == "6m" &&
      azuread_group_member.id.timeouts.delete == "10m"
    )
    error_message = "Single memberships must pass IDs and all supported timeouts."
  }
}

run "key_based_memberships_pass_all_collection_timeouts" {
  command = plan
  module {
    source = "../modules/azuread/groups_members/membership"
  }
  variables {
    group_object_id            = "00000000-0000-0000-0000-000000000001"
    members                    = { keys = ["member"] }
    azuread_groups             = { member = { object_id = "00000000-0000-0000-0000-000000000002" } }
    azuread_service_principals = { member = { object_id = "00000000-0000-0000-0000-000000000003" } }
    managed_identities         = { member = { principal_id = "00000000-0000-0000-0000-000000000004" } }
    mssql_servers              = { member = { rbac_id = "00000000-0000-0000-0000-000000000005" } }
    timeouts                   = { create = "10m", read = "6m", delete = "10m" }
  }
  assert {
    condition = (
      azuread_group_member.group_ids["member"].member_object_id == "00000000-0000-0000-0000-000000000002" &&
      azuread_group_member.ids["member"].member_object_id == "00000000-0000-0000-0000-000000000003" &&
      azuread_group_member.msi_ids["member"].member_object_id == "00000000-0000-0000-0000-000000000004" &&
      azuread_group_member.mssql_server_ids["member"].member_object_id == "00000000-0000-0000-0000-000000000005" &&
      azuread_group_member.group_ids["member"].timeouts.create == "10m" &&
      azuread_group_member.ids["member"].timeouts.read == "6m" &&
      azuread_group_member.msi_ids["member"].timeouts.delete == "10m" &&
      azuread_group_member.mssql_server_ids["member"].timeouts.create == "10m"
    )
    error_message = "All membership collections must retain their ID source and timeout settings."
  }
}
