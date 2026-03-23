global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {}

pim = {
  pim_active_role_assignments = {
    example_active = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      justification      = "Required for production access"

      schedule = {
        start_date_time = "2025-01-01T00:00:00Z"
        expiration = {
          duration_hours = 8
        }
      }

      ticket = {
        number = "TICKET-001"
        system = "ServiceNow"
      }
    }
  }

  pim_eligible_role_assignments = {
    example_eligible = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      justification      = "Eligible for on-demand access"

      schedule = {
        expiration = {
          duration_days = 30
        }
      }
    }
  }
}
