mock_provider "azuread" {}

run "parent_resolves_group_alias_and_propagates_timeouts" {
  command = plan
  module {
    source = "../modules/azuread/groups_members"
  }
  variables {
    client_config   = { landingzone_key = "local" }
    group_object_id = "00000000-0000-0000-0000-000000000001"
    settings = {
      members  = { object_ids = ["00000000-0000-0000-0000-000000000002"] }
      timeouts = { create = "10m", read = "6m", delete = "10m" }
    }
  }
  assert {
    condition = (
      output.memberships.object_ids["00000000-0000-0000-0000-000000000002"].resource.group_object_id == var.group_object_id &&
      output.memberships.object_ids["00000000-0000-0000-0000-000000000002"].resource.timeouts.create == "10m"
    )
    error_message = "An omitted group_id must fall back to group_object_id and pass parent timeouts."
  }
}

run "collection_timeouts_override_parent_defaults" {
  command = plan
  module {
    source = "../modules/azuread/groups_members"
  }
  variables {
    client_config = { landingzone_key = "local" }
    group_key     = "group"
    azuread_groups = {
      local = { group = { object_id = "00000000-0000-0000-0000-000000000001" } }
    }
    managed_identities = {
      local = { member = { principal_id = "00000000-0000-0000-0000-000000000002" } }
    }
    settings = {
      timeouts = { create = "10m", read = "6m", delete = "10m" }
      managed_identities = {
        contract = {
          keys     = ["member"]
          timeouts = { create = "20m", read = "7m", delete = "20m" }
        }
      }
    }
  }
  assert {
    condition = (
      output.memberships.managed_identities.contract.memberships.managed_identities.member.member_object_id == "00000000-0000-0000-0000-000000000002" &&
      output.memberships.managed_identities.contract.memberships.managed_identities.member.timeouts.create == "20m"
    )
    error_message = "Collection timeout overrides must reach key-resolved membership resources."
  }
}

run "omitted_collection_timeouts_inherit_parent_settings" {
  command = plan
  module {
    source = "../modules/azuread/groups_members"
  }
  variables {
    client_config = { landingzone_key = "local" }
    group_key     = "group"
    azuread_groups = {
      local = { group = { object_id = "00000000-0000-0000-0000-000000000001" } }
    }
    managed_identities = {
      local = { member = { principal_id = "00000000-0000-0000-0000-000000000002" } }
    }
    settings = {
      timeouts = { create = "10m", read = "6m", delete = "10m" }
      managed_identities = {
        contract = {
          keys = ["member"]
        }
      }
    }
  }
  assert {
    condition = (
      output.memberships.managed_identities.contract.memberships.managed_identities.member.timeouts.create == "10m" &&
      output.memberships.managed_identities.contract.memberships.managed_identities.member.timeouts.read == "6m" &&
      output.memberships.managed_identities.contract.memberships.managed_identities.member.timeouts.delete == "10m"
    )
    error_message = "An omitted collection timeouts attribute must inherit settings.timeouts."
  }
}

run "explicit_null_collection_timeouts_suppress_inheritance" {
  command = plan
  module {
    source = "../modules/azuread/groups_members"
  }
  variables {
    client_config = { landingzone_key = "local" }
    group_key     = "group"
    azuread_groups = {
      local = { group = { object_id = "00000000-0000-0000-0000-000000000001" } }
    }
    managed_identities = {
      local = { member = { principal_id = "00000000-0000-0000-0000-000000000002" } }
    }
    settings = {
      timeouts = { create = "10m", read = "6m", delete = "10m" }
      managed_identities = {
        contract = {
          keys     = ["member"]
          timeouts = null
        }
      }
    }
  }
  assert {
    condition     = output.memberships.managed_identities.contract.memberships.managed_identities.member.timeouts == null
    error_message = "An explicit null collection timeouts attribute must suppress inheritance."
  }
}
