# Object ID Resolution Flow in CAF Framework

This document explains how the CAF framework resolves object IDs for role assignments, particularly for the `logged_in` user scenario.

## Overview

The CAF framework has a sophisticated system for resolving object IDs that supports multiple authentication scenarios:
1. **Interactive user sessions** (Azure CLI, VS Code)
2. **Service principal authentication** (CI/CD pipelines)
3. **Managed identity authentication** (Azure resources)

## Object ID Resolution Logic

### 1. Primary Object ID Resolution (`locals.tf`)

The main object ID resolution happens in `locals.tf` using a `coalesce` pattern:

```hcl
object_id = coalesce(
  var.logged_user_objectId,                                    # Explicitly provided user object ID
  var.logged_aad_app_objectId,                                 # Explicitly provided app object ID
  try(data.azuread_client_config.current.object_id, null),     # Current Azure AD client object ID
  try(data.azuread_service_principal.logged_in_app[0].object_id, null) # Service principal object ID
)
```

### 2. Client Config Construction (`locals.tf`)

The resolved object ID is used to construct the `client_config` local:

```hcl
client_config = var.client_config == {} ? {
  client_id               = data.azuread_client_config.current.client_id
  landingzone_key         = var.current_landingzone_key
  logged_aad_app_objectId = local.object_id
  logged_user_objectId    = local.object_id
  object_id               = local.object_id
  subscription_id         = data.azurerm_client_config.current.subscription_id
  tenant_id               = data.azurerm_client_config.current.tenant_id
} : tomap(var.client_config)
```

### 3. Logged In Identity Mapping (`roles.tf`)

The `logged_in` service is mapped to provide both user and app contexts:

```hcl
logged_in = tomap({
  (var.current_landingzone_key) = {
    user = {
      rbac_id = local.client_config.logged_user_objectId
    }
    app = {
      rbac_id = local.client_config.logged_aad_app_objectId
    }
  }
})
```

### 4. Services Roles Registration

The `logged_in` mapping is registered in the `services_roles` collection:

```hcl
services_roles = {
  # ... other services ...
  logged_in = local.logged_in
  # ... other services ...
}
```

### 5. Role Assignment Resolution

When processing role assignments, the framework resolves the principal ID:

```hcl
# For the legacy role assignment pattern
principal_id = each.value.object_id_resource_type == "object_ids" ? 
  each.value.object_id_key_resource : 
  each.value.object_id_lz_key == null ? 
    local.services_roles[each.value.object_id_resource_type][var.current_landingzone_key][each.value.object_id_key_resource].rbac_id : 
    local.services_roles[each.value.object_id_resource_type][each.value.object_id_lz_key][each.value.object_id_key_resource].rbac_id
```

## Authentication Scenarios

### Scenario 1: Interactive User (Azure CLI/VS Code)

```bash
# User logs in with Azure CLI
az login

# Or authenticates through VS Code Azure extension
```

**Resolution Flow:**
1. `data.azuread_client_config.current.object_id` returns the user's object ID
2. `local.object_id` = user's object ID
3. `local.client_config.logged_user_objectId` = user's object ID
4. Role assignment resolves to the user's identity

### Scenario 2: Service Principal (CI/CD)

```bash
# Environment variables set in CI/CD
export ARM_CLIENT_ID="service-principal-client-id"
export ARM_CLIENT_SECRET="service-principal-secret"
export ARM_SUBSCRIPTION_ID="subscription-id"
export ARM_TENANT_ID="tenant-id"
```

**Resolution Flow:**
1. `data.azuread_service_principal.logged_in_app[0].object_id` returns the SP's object ID
2. `local.object_id` = service principal's object ID
3. `local.client_config.logged_aad_app_objectId` = service principal's object ID
4. Role assignment resolves to the service principal's identity

### Scenario 3: Explicit Configuration

```hcl
# Terraform variables
client_config = {
  logged_user_objectId = "explicit-user-object-id"
  logged_aad_app_objectId = "explicit-app-object-id"
  # ... other config
}
```

**Resolution Flow:**
1. `var.client_config` is provided explicitly
2. Uses the provided object IDs directly
3. No automatic resolution needed

## Role Mapping Usage

### RBAC Pattern (Recommended)

```hcl
# role_mapping.tfvars
role_mapping = {
  built_in_role_mapping = {
    keyvaults = {
      my_kv = {
        "Key Vault Administrator" = {
          logged_in = {
            keys = ["user"]  #e mo Resolves to logged_user_objectId
          }
        }
        "Key Vault Certificates User" = {
          managed_identities = {
            keys = ["my_service_identity"]
          }
        }
      }
    }
  }
}
```

### Resolution Process

1. `logged_in = { keys = ["user"] }` tells the framework to look up the logged_in service
2. Framework finds `local.services_roles["logged_in"][landingzone_key]["user"].rbac_id`
3. This resolves to `local.client_config.logged_user_objectId`
4. The final principal_id becomes the user's object ID

## Data Sources

### Required Data Sources

```hcl
# Provides client_id and object_id for current Azure AD context
data "azuread_client_config" "current" {}

# Provides subscription_id and tenant_id for current Azure context
data "azurerm_client_config" "current" {}

# Conditionally created for service principal scenarios
data "azuread_service_principal" "logged_in_app" {
  count     = var.logged_aad_app_objectId == null ? 0 : 1
  client_id = data.azuread_client_config.current.client_id
}
```

## Debugging Tips

### Verify Object ID Resolution

```hcl
# Add to outputs for debugging
output "debug_object_id" {
  value = local.object_id
}

output "debug_client_config" {
  value = local.client_config
  sensitive = true
}
```

### Check Current Identity

```bash
# Check current Azure CLI identity
az account show --query "user.name" -o tsv

# Check current Azure AD identity
az ad signed-in-user show --query "objectId" -o tsv
```

### Validate Role Assignments

```bash
# List role assignments for a specific scope
az role assignment list --scope "/subscriptions/sub-id/resourceGroups/rg-name/providers/Microsoft.KeyVault/vaults/kv-name" --query "[].{principalId:principalId,roleDefinitionName:roleDefinitionName,principalType:principalType}" -o table
```

## Common Issues and Solutions

### Issue: "Principal not found" Error

**Cause:** Object ID resolution failed or returned null
**Solution:** Verify authentication and check data source availability

### Issue: Wrong Principal ID in Role Assignment

**Cause:** Mixed authentication contexts (user vs service principal)
**Solution:** Explicitly set `client_config` or use consistent authentication

### Issue: Role Assignment Propagation Delays

**Cause:** Azure AD role assignments take time to propagate
**Solution:** Add retry logic or wait time in deployment scripts

## Best Practices

1. **Use explicit client_config in CI/CD** to avoid resolution ambiguity
2. **Verify object IDs** before production deployments
3. **Use RBAC** instead of access policies for Key Vault
4. **Handle propagation delays** in automated deployments
5. **Test role assignments** with different authentication contexts

## Related Files

- `locals.tf` - Object ID resolution logic
- `main.tf` - Data source definitions
- `roles.tf` - Role assignment and mapping logic
- `modules/roles/role_assignment/` - Role assignment module implementation
