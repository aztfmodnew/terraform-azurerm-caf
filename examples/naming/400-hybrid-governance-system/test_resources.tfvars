# Comparison Test Resources
# Same resources with different governance settings to compare outcomes

container_app_environments = {
  test_flexible = {
    name               = "webapp"
    resource_group_key = "test_rg"

    # This override will be applied in flexible mode, ignored in strict mode
    naming = {
      prefix      = "custom"
      environment = "testing"
      separator   = "."
    }
  }

  test_standard = {
    name               = "api"
    resource_group_key = "test_rg"
    # No naming override - always follows patterns
  }
}

storage_accounts = {
  test_storage = {
    name               = "documents"
    resource_group_key = "test_rg"

    # Storage account specific testing
    naming = {
      prefix = "override" # Will be ignored in strict mode
    }
  }
}

resource_groups = {
  test_rg = {
    name = "test-naming-governance"
  }
}
