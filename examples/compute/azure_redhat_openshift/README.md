# Azure Red Hat OpenShift (ARO) Examples

This directory contains examples for deploying Azure Red Hat OpenShift clusters using the CAF framework.

## Service Principal Configuration

ARO requires specific role assignments to the Azure Red Hat OpenShift Resource Provider service principal. The CAF framework now supports two approaches for configuring these role assignments:

### Option 1: Using azuread_service_principal_names (Recommended)

This is the new, preferred approach that automatically resolves service principal display names to object IDs:

```hcl
azuread = {
  azuread_service_principal_names = {
    aro_rp = {
      display_name = "Azure Red Hat OpenShift RP"
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    networking = {
      vnet1 = {
        "Contributor" = {
          azuread_service_principal_names = {
            keys = ["aro_rp"]
          }
        }
      }
    }
  }
}
```

**Benefits:**

- Tenant-agnostic - works across different Azure AD tenants
- No need to manually look up object IDs
- Automatically resolves service principal names to object IDs
- More maintainable and readable

**Prerequisites:**

- The service principal must exist in your tenant
- You can verify with: `az ad sp list --display-name "Azure Red Hat OpenShift RP" --query "[0].id" -o tsv`

### Option 2: Using object_ids (Legacy)

This is the legacy approach using hardcoded object IDs:

```hcl
role_mapping = {
  built_in_role_mapping = {
    networking = {
      vnet1 = {
        "Contributor" = {
          object_ids = {
            keys = ["004c3094-aa2e-47f3-87aa-f82a155ada54"]
          }
        }
      }
    }
  }
}
```

**Drawbacks:**

- Tenant-specific - object IDs vary between tenants
- Requires manual lookup of object IDs
- Less maintainable

**When to use:**

- CI/CD environments where the ARO RP might not be available
- Temporary workaround during testing
- When you need to use a specific object ID

### Migration Guide

To migrate from object_ids to azuread_service_principal_names:

1. **Add the azuread section** with service principal name configuration
2. **Update role_mapping** to use azuread_service_principal_names
3. **Comment out or remove** the object_ids section
4. **Test the deployment** to ensure it works in your tenant

Example migration:

```hcl
# Before (legacy)
role_mapping = {
  built_in_role_mapping = {
    networking = {
      vnet1 = {
        "Contributor" = {
          object_ids = {
            keys = ["004c3094-aa2e-47f3-87aa-f82a155ada54"]
          }
        }
      }
    }
  }
}

# After (recommended)
azuread = {
  azuread_service_principal_names = {
    aro_rp = {
      display_name = "Azure Red Hat OpenShift RP"
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    networking = {
      vnet1 = {
        "Contributor" = {
          azuread_service_principal_names = {
            keys = ["aro_rp"]
          }
        }
      }
    }
  }
}
```

## Examples

- `101_basic_private_cluster/` - Basic private ARO cluster configuration
- `102_basic_public_cluster/` - Basic public ARO cluster configuration

Both examples are configured to use object_ids by default for CI/CD compatibility, but include commented examples showing how to use azuread_service_principal_names.

## Troubleshooting

### Service Principal Not Found

If you get an error about the service principal not being found:

1. **Verify the service principal exists:**

   ```bash
   az ad sp list --display-name "Azure Red Hat OpenShift RP" --query "[0].{id:id,displayName:displayName}" -o table
   ```

2. **Check your tenant has ARO enabled:**
   - ARO must be enabled in your subscription
   - The service principal is automatically created when ARO is first used

3. **Use the legacy object_ids approach** as a fallback:
   ```bash
   # Get the object ID manually
   az ad sp list --display-name "Azure Red Hat OpenShift RP" --query "[0].id" -o tsv
   ```

### Role Assignment Failures

If role assignments fail:

1. **Check permissions** - you need sufficient permissions to assign roles
2. **Verify the scope** - ensure the networking resources exist
3. **Check the role definition** - "Contributor" should be available
4. **Review timing** - there might be eventual consistency delays

For more information, see the [Azure Red Hat OpenShift documentation](https://docs.microsoft.com/en-us/azure/openshift/).
