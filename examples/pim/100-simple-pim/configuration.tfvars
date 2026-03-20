global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
}

pim = {
  # Active role assignments: immediately grants the role for a limited time window.
  pim_active_role_assignments = {
    example_active = {
      # Replace with the actual subscription or resource scope
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
      # Replace with the role definition ID (e.g. Reader, Contributor, custom role)
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
      # Replace with the user, group, or service principal object ID
      principal_id  = "00000000-0000-0000-0000-000000000000"
      justification = "Temporary access for incident response"

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

  # Eligible role assignments: makes a principal eligible to activate the role on demand.
  pim_eligible_role_assignments = {
    example_eligible = {
      # Replace with the actual subscription or resource scope
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
      # Replace with the role definition ID (e.g. Reader, Contributor, custom role)
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
      # Replace with the user, group, or service principal object ID
      principal_id  = "00000000-0000-0000-0000-000000000000"
      justification = "Eligible for on-call duties"

      schedule = {
        start_date_time = "2025-01-01T00:00:00Z"
        expiration = {
          duration_days = 30
        }
      }

      ticket = {
        number = "TICKET-002"
        system = "ServiceNow"
      }
    }
  }

  # Eligible assignment schedules: scheduled eligibility with explicit start time and expiration.
  pim_eligible_assignment_schedules = {
    example_schedule = {
      # Replace with the actual subscription or resource scope
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000"
      # Replace with the role definition ID (e.g. Reader, Contributor, custom role)
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000"
      # Replace with the user, group, or service principal object ID
      principal_id  = "00000000-0000-0000-0000-000000000000"
      justification = "Scheduled eligibility for quarterly access"

      schedule = {
        start_date_time = "2025-01-01T00:00:00Z"
        expiration = {
          duration_days = 90
        }
      }

      ticket = {
        number = "TICKET-003"
        system = "ServiceNow"
      }
    }
  }
}
