mock_provider "azurerm" {
  source = "./tests/mock_data"
}
mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}
mock_provider "azuread" {
  source = "./tests/mock_data"
}
mock_provider "azapi" {
  source = "./tests/mock_data"
}
mock_provider "external" {
  source = "./tests/mock_data"
}

run "root_resolves_explicit_group_key_and_exports_memberships" {
  command = plan
  module {
    source = "../"
  }
  variables {
    global_settings = {
      default_region = "region1"
      regions        = { region1 = "westeurope" }
      random_length  = 0
    }
    data_sources = {
      azuread_groups = {
        destination = { object_id = "00000000-0000-0000-0000-000000000001" }
      }
    }
    azuread = {
      azuread_groups_membership = {
        different_entry_name = {
          key        = "destination"
          object_ids = { member = "00000000-0000-0000-0000-000000000002" }
          timeouts   = { create = "10m", read = "6m", delete = "10m" }
        }
      }
    }
  }
  assert {
    condition = (
      output.azuread_groups_membership.different_entry_name.memberships.membership_object_ids.member.resource.group_object_id == "00000000-0000-0000-0000-000000000001" &&
      output.azuread_groups_membership.different_entry_name.memberships.membership_object_ids.member.resource.member_object_id == "00000000-0000-0000-0000-000000000002" &&
      output.azuread_groups_membership.different_entry_name.memberships.membership_object_ids.member.resource.timeouts.create == "10m"
    )
    error_message = "Root membership entries must honor explicit group keys, propagate timeouts and expose membership outputs."
  }
}
