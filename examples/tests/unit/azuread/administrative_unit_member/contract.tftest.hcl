mock_provider "azuread" {}

variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
}

run "direct_ids_take_precedence_and_pass_timeouts" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { id = "00000000-0000-0000-0000-000000000001", key = "missing" }
      member_object              = { id = "00000000-0000-0000-0000-000000000002", key = "missing" }
      timeouts                   = { create = "10m", read = "6m", delete = "10m" }
    }
  }
  assert {
    condition = (
      azuread_administrative_unit_member.admum.administrative_unit_object_id == "00000000-0000-0000-0000-000000000001" &&
      azuread_administrative_unit_member.admum.member_object_id == "00000000-0000-0000-0000-000000000002" &&
      azuread_administrative_unit_member.admum.timeouts.create == "10m" &&
      azuread_administrative_unit_member.admum.timeouts.read == "6m" &&
      azuread_administrative_unit_member.admum.timeouts.delete == "10m"
    )
    error_message = "Direct IDs must win over unresolved keys and timeouts must reach the provider."
  }
}

run "resolves_local_and_remote_keys_with_null_direct_ids" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { id = null, key = "unit" }
      member_object              = { id = null, key = "group", lz_key = "remote", resource_type = "azuread_groups" }
    }
    remote_objects = {
      azuread_administrative_units = {
        local = { unit = { object_id = "00000000-0000-0000-0000-000000000003" } }
      }
      azuread_groups = {
        remote = { group = { object_id = "00000000-0000-0000-0000-000000000004" } }
      }
    }
  }
  assert {
    condition = (
      azuread_administrative_unit_member.admum.administrative_unit_object_id == "00000000-0000-0000-0000-000000000003" &&
      azuread_administrative_unit_member.admum.member_object_id == "00000000-0000-0000-0000-000000000004"
    )
    error_message = "Null direct IDs must allow same-landing-zone and remote-key resolution."
  }
}

run "rejects_member_without_id_or_key" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { id = "00000000-0000-0000-0000-000000000001" }
      member_object              = { lz_key = "remote", resource_type = "azuread_groups" }
    }
  }
  expect_failures = [var.settings]
}

run "rejects_key_based_member_without_supported_resource_type" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { id = "00000000-0000-0000-0000-000000000001" }
      member_object              = { key = "group" }
    }
  }
  expect_failures = [var.settings]
}

run "rejects_administrative_unit_without_id_or_key" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { lz_key = "remote" }
      member_object              = { id = "00000000-0000-0000-0000-000000000002" }
    }
  }
  expect_failures = [var.settings]
}

run "rejects_member_with_empty_key" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { id = "00000000-0000-0000-0000-000000000001" }
      member_object              = { key = "", resource_type = "azuread_groups" }
    }
  }
  expect_failures = [var.settings]
}

run "rejects_administrative_unit_with_empty_id" {
  command = plan
  module {
    source = "../modules/azuread/administrative_unit_member"
  }
  variables {
    settings = {
      administrative_unit_object = { id = "" }
      member_object              = { id = "00000000-0000-0000-0000-000000000002" }
    }
  }
  expect_failures = [var.settings]
}
