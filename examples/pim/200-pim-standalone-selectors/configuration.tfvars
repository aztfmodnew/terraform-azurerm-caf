# =============================================================================
# PIM 200 — Standalone Selectors Example
#
# PURPOSE: Demonstrates ALL selector modes introduced in the PIM submodules:
#   1. Key-based references  — resolved via remote_objects (combined_objects)
#   2. Standalone data-source selectors — resolved via provider data sources
#      using display_name / name / subscription_id, without CAF keys.
#
# IMPORTANT: Selectors that require real Azure objects (management groups,
# subscriptions, Azure AD groups, user-assigned identities) use SANITIZED
# PLACEHOLDER values and are kept COMMENTED OUT.  Uncomment a block and
# replace placeholder values with real ones before applying.
#
# The key-based blocks (azuread_groups, managed_identities) use resources
# created within this example and are fully runnable in mock/plan mode.
# =============================================================================

global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  pim_rg = {
    name = "pim-selectors-test"
  }
}

# ---------------------------------------------------------------------------
# Intra-example resources referenced by key-based selectors
# ---------------------------------------------------------------------------

azuread_groups = {
  pim_grp = {
    name = "pim-selectors-group-1"
  }
}

managed_identities = {
  pim_mi = {
    name               = "pim-selectors-identity-1"
    resource_group_key = "pim_rg"
  }
}

# ---------------------------------------------------------------------------
# data_sources — Standalone selectors (commented — require real tenant values)
#
# Uncomment one or more blocks below and replace every placeholder enclosed
# in <ANGLE_BRACKETS> before running terraform plan / apply.
# ---------------------------------------------------------------------------

# data_sources = {
#
#   # ── Management Group selector ─────────────────────────────────────────
#   # Resolves scope by display_name (human-readable) or internal name.
#   # Exactly one of display_name / name must be provided.
#   management_groups = {
#     platform_mg = {
#       display_name = "<REPLACE: e.g. Platform>"
#       # Alternative: use the internal management group name (GUID or slug)
#       # name = "<REPLACE: e.g. platform-mg-id>"
#     }
#   }
#
#   # ── Subscription selector ─────────────────────────────────────────────
#   # Option A: resolve by subscription_id (deterministic, preferred)
#   subscriptions = {
#     target_subscription = {
#       subscription_id = "<REPLACE: 00000000-0000-0000-0000-000000000000>"
#     }
#     # Option B: resolve by display_name (must be unique in tenant)
#     # target_subscription_by_name = {
#     #   display_name = "<REPLACE: My Production Subscription>"
#     # }
#   }
#
#   # ── Role definition selector ──────────────────────────────────────────
#   # Resolve a built-in or custom role by human-friendly name.
#   role_definitions = {
#     reader_builtin = {
#       name = "Reader"
#       # scope is optional; defaults to "/" (tenant root)
#       # scope = "<REPLACE: /subscriptions/00000000-0000-0000-0000-000000000000>"
#     }
#     storage_blob_contributor = {
#       name = "Storage Blob Data Contributor"
#     }
#   }
#
#   # ── Azure AD group selector ───────────────────────────────────────────
#   # Resolves principal_id for an existing Azure AD group by display_name.
#   azuread_groups = {
#     existing_ad_group = {
#       display_name = "<REPLACE: e.g. platform-ops-team>"
#     }
#   }
#
#   # ── User-assigned managed identity selector ───────────────────────────
#   # Resolves principal_id for an existing UAMI by name + resource_group_name.
#   managed_identities = {
#     existing_uami = {
#       name                = "<REPLACE: my-existing-identity>"
#       resource_group_name = "<REPLACE: rg-my-existing-identity>"
#     }
#   }
# }

# =============================================================================
# PIM assignments and policies
# =============================================================================

pim = {

  # ---------------------------------------------------------------------------
  # Active role assignments
  # ---------------------------------------------------------------------------
  pim_active_role_assignments = {

    # ── Selector mode A: key-based — managed identity created in this example ─
    active_via_mi_key = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Active assignment via managed-identity key selector"

      # Key-based: resolved from managed_identities combined_objects
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
        number = "TICKET-200-A"
        system = "ServiceNow"
      }
    }

    # ── Selector mode B: key-based — Azure AD group created in this example ───
    active_via_group_key = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Active assignment via Azure AD group key selector"

      # Key-based: resolved from azuread_groups combined_objects
      azuread_group = {
        key = "pim_grp"
      }
    }

    # ── Selector mode C: direct principal_id (no resolver) ────────────────────
    active_via_direct_principal = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      justification      = "Active assignment via direct principal_id (no resolver needed)"
    }

    # ── Selector mode D: standalone management_group display_name selector ────
    # Requires real management group in tenant.  Uncomment + replace values.
    # active_via_mg_display_name = {
    #   # Scope resolved by management group display_name via data source
    #   management_group = {
    #     display_name = "<REPLACE: e.g. Platform>"
    #   }
    #
    #   # Role resolved by built-in role name via data source
    #   role_definition = {
    #     name = "Reader"
    #   }
    #
    #   # Principal resolved by Azure AD group display_name via data source
    #   azuread_group = {
    #     display_name = "<REPLACE: e.g. platform-ops-team>"
    #   }
    #
    #   justification = "Active assignment via all standalone display_name selectors"
    # }

    # ── Selector mode E: standalone subscription selector ─────────────────────
    # Requires real subscription.  Uncomment + replace values.
    # active_via_subscription_id = {
    #   # Scope resolved by subscription_id via data source
    #   subscription = {
    #     subscription_id = "<REPLACE: 00000000-0000-0000-0000-000000000000>"
    #   }
    #
    #   role_definition = {
    #     name = "Reader"
    #   }
    #
    #   # Principal resolved by UAMI name + resource_group_name via data source
    #   managed_identity = {
    #     name                = "<REPLACE: my-existing-identity>"
    #     resource_group_name = "<REPLACE: rg-my-existing-identity>"
    #   }
    #
    #   justification = "Active assignment via standalone subscription_id and UAMI selectors"
    # }

    # ── Selector mode F: standalone subscription display_name selector ────────
    # Requires subscription whose display_name is unique in tenant.
    # active_via_subscription_display_name = {
    #   subscription = {
    #     display_name = "<REPLACE: My Production Subscription>"
    #   }
    #
    #   role_definition = {
    #     name = "Reader"
    #   }
    #
    #   principal_id = "00000000-0000-0000-0000-000000000000"
    #
    #   justification = "Active assignment resolved via subscription display_name"
    # }
  }

  # ---------------------------------------------------------------------------
  # Eligible role assignments
  # ---------------------------------------------------------------------------
  pim_eligible_role_assignments = {

    # ── Key-based managed identity eligible ───────────────────────────────────
    eligible_via_mi_key = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Eligible assignment via managed-identity key selector"

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
        number = "TICKET-200-B"
        system = "ServiceNow"
      }
    }

    # ── Key-based Azure AD group eligible ─────────────────────────────────────
    eligible_via_group_key = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      justification      = "Eligible assignment via Azure AD group key selector"

      azuread_group = {
        key = "pim_grp"
      }

      schedule = {
        expiration = {
          duration_days = 30
        }
      }
    }

    # ── Eligible with ABAC condition ──────────────────────────────────────────
    eligible_with_abac_condition = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
      principal_id       = "00000000-0000-0000-0000-000000000000"
      justification      = "Eligible with ABAC condition restricting access to 'logs' container"
      condition          = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'logs'"
      condition_version  = "2.0"

      schedule = {
        expiration = {
          duration_hours = 8
        }
      }
    }

    # ── Standalone management_group name selector (eligible) ──────────────────
    # Requires real management group.  Uncomment + replace values.
    # eligible_via_mg_name = {
    #   # Scope resolved by internal management group name (GUID or slug)
    #   management_group = {
    #     name = "<REPLACE: e.g. platform>"
    #   }
    #
    #   role_definition = {
    #     name = "Reader"
    #   }
    #
    #   azuread_group = {
    #     display_name = "<REPLACE: e.g. platform-ops-team>"
    #   }
    #
    #   justification = "Eligible assignment via standalone management_group name selector"
    # }

    # ── Standalone subscription selector (eligible) ───────────────────────────
    # eligible_via_subscription = {
    #   subscription = {
    #     subscription_id = "<REPLACE: 00000000-0000-0000-0000-000000000000>"
    #   }
    #
    #   role_definition = {
    #     name = "Storage Blob Data Contributor"
    #   }
    #
    #   managed_identity = {
    #     name                = "<REPLACE: my-existing-identity>"
    #     resource_group_name = "<REPLACE: rg-my-existing-identity>"
    #   }
    #
    #   justification = "Eligible assignment via standalone subscription and UAMI selectors"
    # }
  }

  # ---------------------------------------------------------------------------
  # Role management policies
  # ---------------------------------------------------------------------------
  pim_role_management_policies = {

    # ── Policy via direct scope + role_definition_id ──────────────────────────
    policy_allow_permanent_active = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"

      active_assignment_rules = {
        expiration_required = false
      }

      eligible_assignment_rules = {
        expiration_required = false
      }
    }

    # ── Policy via standalone management_group display_name selector ──────────
    # Requires real management group.  Uncomment + replace values.
    # policy_via_mg_display_name = {
    #   management_group = {
    #     display_name = "<REPLACE: e.g. Platform>"
    #   }
    #
    #   role_definition = {
    #     name = "Reader"
    #   }
    #
    #   active_assignment_rules = {
    #     expiration_required = true
    #   }
    # }

    # ── Policy via standalone subscription selector ────────────────────────────
    # policy_via_subscription = {
    #   subscription = {
    #     subscription_id = "<REPLACE: 00000000-0000-0000-0000-000000000000>"
    #   }
    #
    #   role_definition = {
    #     name = "Contributor"
    #   }
    #
    #   eligible_assignment_rules = {
    #     expiration_required = true
    #   }
    # }
  }

}
