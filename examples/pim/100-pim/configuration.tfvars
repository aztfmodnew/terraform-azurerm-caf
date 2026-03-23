global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  pim_rg = {
    name = "pim-test-1"
  }
}


azuread_groups = {
  pim_grp = {
    name = "pim-test-group-1"
  }
}

managed_identities = {
  pim_mi = {
    name               = "pim-identity-1"
    resource_group_key = "pim_rg"
  }
}

pim = {
  pim_active_role_assignments = {
    # Example 1: active assignment resolved via managed identity key
    example_active_mi = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Required for production access"

      managed_identity = {
        key = "pim_mi"
      }

      schedule = {
        start_date_time = "2026-01-01T00:00:00Z"
        expiration = {
          duration_hours = 8
        }
      }

      ticket = {
        number = "TICKET-001"
        system = "ServiceNow"
      }
    }

    # Example 2: active assignment via direct principal_id
    example_active_direct = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      justification      = "Required for production access (direct)"
    }

    # Example 3: active assignment resolved via Azure AD group key
    example_active_group = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Required for group production access"

      azuread_group = {
        key = "pim_grp"
      }
    }
  }

  pim_eligible_role_assignments = {
    # Example 3: eligible assignment via managed identity key
    example_eligible_mi = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Eligible for on-demand access"

      managed_identity = {
        key = "pim_mi"
      }

      schedule = {
        start_date_time = "2026-01-01T00:00:00Z"
        expiration = {
          duration_days = 30
        }
      }

      ticket = {
        number = "TICKET-002"
        system = "ServiceNow"
      }
    }

    # Example 4: eligible assignment with ABAC condition
    example_eligible_with_condition = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      justification      = "Eligible with ABAC condition restricting to 'logs' container"
      condition          = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'logs'"
      condition_version  = "2.0"

      schedule = {
        expiration = {
          duration_hours = 8
        }
      }
    }

    # Example 5: eligible assignment resolved via Azure AD group key
    example_eligible_group = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Eligible via group assignment"

      azuread_group = {
        key = "pim_grp"
      }

      schedule = {
        expiration = {
          duration_days = 30
        }
      }
    }
  }
}
