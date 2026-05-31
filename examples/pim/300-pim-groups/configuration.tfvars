global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

azuread_groups = {
  pim_target_group = {
    name = "pim-target-group-1"
  }

  pim_principal_group = {
    name = "pim-principal-group-1"
  }
}

pim = {
  pim_group_assignments = {
    eligible_member_assignment = {
      assignment_mode = "eligible"
      assignment_type = "member"

      group = {
        key = "pim_target_group"
      }

      principal_group = {
        key = "pim_principal_group"
      }

      justification = "Eligible assignment for privileged group membership"
      duration      = "P30D"
    }

    active_owner_assignment = {
      assignment_mode = "active"
      assignment_type = "owner"
      group = {
        key = "pim_target_group"
      }

      principal_group = {
        key = "pim_principal_group"
      }

      permanent_assignment = true
      justification        = "Active owner assignment for emergency operations"
      ticket_system        = "ServiceNow"
      ticket_number        = "INC-30001"
    }
  }
}
