# PIM — 200 Standalone Selectors Example

## Overview

This example demonstrates **every selector mode** supported by the PIM submodules
(`pim_active_role_assignments`, `pim_eligible_role_assignments`,
`pim_role_management_policies`), covering both active and eligible assignments as
well as role management policies.

### Selector modes shown

| Mode | Description | Runnable without real tenant? |
|------|-------------|-------------------------------|
| **Key-based** (`key`) | Resolves via CAF combined_objects (resources created in this example) | ✅ Yes |
| **Direct IDs** (`scope`, `role_definition_id`, `principal_id`) | No resolution needed | ✅ Yes (placeholder UUIDs) |
| **`management_group.display_name`** | Resolves scope via `azurerm_management_group` data source | ❌ Commented — needs real tenant |
| **`management_group.name`** | Resolves scope via `azurerm_management_group` data source | ❌ Commented — needs real tenant |
| **`subscription.subscription_id`** | Resolves scope via `azurerm_subscription` data source | ❌ Commented — needs real tenant |
| **`subscription.display_name`** | Resolves scope via tenant-wide subscription search | ❌ Commented — needs real tenant |
| **`role_definition.name`** | Resolves role ID via `azurerm_role_definition` data source | ❌ Commented — needs real tenant |
| **`azuread_group.display_name`** | Resolves `principal_id` via `azuread_group` data source | ❌ Commented — needs real tenant |
| **`managed_identity.name + resource_group_name`** | Resolves `principal_id` via `azurerm_user_assigned_identity` data source | ❌ Commented — needs real tenant |

## Resources deployed (active blocks)

- 1 Resource Group
- 1 Azure AD Group (`pim-selectors-group-1`)
- 1 User-Assigned Managed Identity (`pim-selectors-identity-1`)
- 3 PIM Active Role Assignments (key-based and direct)
- 3 PIM Eligible Role Assignments (key-based, direct, ABAC condition)
- 1 PIM Role Management Policy (direct scope)

## Using the standalone selectors (commented blocks)

1. Open `configuration.tfvars`.
2. Uncomment the `data_sources` block and any assignment blocks you want.
3. Replace every `<REPLACE: ...>` placeholder with a real value from your tenant.
4. Run the standard deploy steps below.

> **Note**: `subscription.display_name` resolution enforces uniqueness — if
> multiple subscriptions share the same display name Terraform will fail with a
> clear precondition error message.

## Prerequisites

- Terraform >= 1.6.0
- Azure subscription with PIM enabled
- Azure CLI authenticated (`az login`)
- Sufficient permissions:
  - `Microsoft.Authorization/roleAssignments/write` on target scope
  - `Microsoft.Authorization/roleManagementPolicies/update` on target scope
  - Azure AD permissions to create groups (for the example AAD group)

## Deployment

**⚠️ CRITICAL: Verify Azure subscription before deployment**

```bash
# 1. Verify current Azure subscription
az account show --query "{subscriptionId:id, name:name, state:state}" -o table

# 2. Confirm this is the correct subscription — proceed ONLY after confirmation

# 3. Export subscription ID
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# 4. Navigate and deploy
cd examples
terraform init
terraform plan  -var-file="./pim/200-pim-standalone-selectors/configuration.tfvars"
terraform apply -var-file="./pim/200-pim-standalone-selectors/configuration.tfvars"
```

## Mock / plan-only test

The active (uncommented) blocks can be validated without real Azure resources:

```bash
cd examples
terraform test \
  -test-directory=./tests/mock \
  -var-file=./pim/200-pim-standalone-selectors/configuration.tfvars \
  -verbose
```

## Cleanup

```bash
terraform destroy -var-file="./pim/200-pim-standalone-selectors/configuration.tfvars"
```

## Notes

- Standalone selectors trigger provider data-source calls; they require
  `terraform plan` / `apply` against a real Azure tenant with the referenced
  objects already existing.
- Key-based selectors (using `key =`) are the preferred pattern in CAF
  pipelines because they work offline and avoid extra provider round-trips.
- ABAC conditions (`condition` + `condition_version`) are supported on both
  active and eligible assignments.
