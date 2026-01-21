# Dependency Resolution Pattern - Azure CAF Framework

**Last Updated**: January 2026  
**Status**: Production  
**Applies to**: Modules with complex multi-type resource dependencies

---

## Overview

This document describes the **Remote Objects Pattern** for dependency resolution in CAF modules. This is the STANDARD pattern for ALL modules.

### The Problem

When using `coalesce()` with multiple `try()` expressions that ALL might return `null`, Terraform fails during planning:

```hcl
# ❌ THIS FAILS - coalesce cannot handle all-null arguments
target_resource_id = coalesce(
  try(var.settings.target_resource_id, null),
  try(var.remote_objects.storage_accounts[lz_key][resource_key].id, null),
  try(var.remote_objects.virtual_machines[lz_key][resource_key].id, null),
  try(var.remote_objects.aks_clusters[lz_key][resource_key].id, null)
)
```

**Error**: `Call to function "coalesce" failed: no non-null, non-empty-string arguments.`

**Root Cause**: 
- When ALL `try()` expressions evaluate to `null` (e.g., resource not found in any collection)
- `coalesce()` requires at least ONE non-null value
- This commonly happens with multi-type conditional dependencies during planning

---

## Solution Pattern

### Module Layer (Standard Pattern)

ALL dependency resolution happens in module locals using `var.remote_objects`. Choose pattern based on complexity:

**Pattern 1: Single Resource Type (Most Common)**

```hcl
# File: modules/cognitive_services/ai_services/locals.tf

locals {
  lz_key         = try(var.settings.subnet.lz_key, var.client_config.landingzone_key)
  resource_key   = try(var.settings.subnet.key, var.settings.subnet_key)
  
  subnet_id = coalesce(
    try(var.settings.subnet_id, null),  # Direct ID
    try(var.remote_objects.virtual_subnets[local.lz_key][local.resource_key].id, null)  # Key-based
  )
}
```

**Pattern 2: Multi-Type Conditional (Ternary Cascade)**

```hcl
# File: modules/chaos_studio/chaos_studio_target/locals.tf

locals {
  lz_key         = try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)
  resource_key   = try(var.settings.target_resource.key, var.settings.target_resource_key)
  
  # Use ternary cascade based on target_type
  target_resource_id = (
    var.settings.target_resource_id != null ? var.settings.target_resource_id :
    var.settings.target_type == "Microsoft-StorageAccount" ? try(var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-VirtualMachine" ? try(var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-AKSCluster" ? try(var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id, null) :
    null  # Clean fallback, no hardcoded IDs
  )
}
```

**Pattern 3: Using can() for Existence Checks (Less Common)**

```hcl
# Only when you need explicit existence check
locals {
  lz_key         = try(var.settings.resource.lz_key, var.client_config.landingzone_key)
  resource_key   = try(var.settings.resource.key, var.settings.resource_key)
  
  # Check existence first (2 evaluations - slower)
  storage_account_id = can(var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id) 
    ? var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id 
    : null
    
  resource_id = coalesce(
    try(var.settings.resource_id, null),
    local.storage_account_id
  )
}
```

**Performance Note**: `try()` (1 evaluation) is 50% faster than `can()` + ternary (2 evaluations). Use `can()` only when you need explicit existence check.

### Root Aggregator Layer (Pass Dependencies Only)

The aggregator's ONLY job is to pass `remote_objects` to the module. Resolution happens in module locals.

```hcl
# File: chaos_studio_chaos_studio_targets.tf

module "chaos_studio_targets" {
  source   = "./modules/chaos_studio/chaos_studio_target"
  for_each = local.chaos_studio.chaos_studio_targets

  # Add depends_on for explicit ordering if needed
  depends_on = [
    module.storage_accounts,
    module.virtual_machines,
    module.aks_clusters,
    module.azurerm_firewalls
  ]

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[...]
  location        = try(each.value.location, null)
  
  # Pass settings directly, NO resolution here
  settings = each.value
  
  # Pass ALL dependencies the module needs
  remote_objects = {
    resource_groups   = local.combined_objects_resource_groups
    storage_accounts  = local.combined_objects_storage_accounts
    virtual_machines  = local.combined_objects_virtual_machines
    aks_clusters      = local.combined_objects_aks_clusters
    azurerm_firewalls = local.combined_objects_azurerm_firewalls
  }
}
```

**Key Points**:
- ✅ Pass `settings = each.value` directly (no merge, no resolution)
- ✅ Pass all required dependencies in `remote_objects` block
- ✅ Use `depends_on` if module depends on other modules being created first
- ❌ Do NOT resolve IDs in aggregator (module handles this)

---

## Decision Tree: Which Pattern to Use

```
Does the module depend on multiple resource types?
│
├─ NO → Use Pattern 1 (Simple Coalesce)
│        Single try() with coalesce()
│        Most common pattern
│
└─ YES → Is the resolution conditional based on a TYPE setting?
          │
          ├─ NO → Use Pattern 1 (Simple Coalesce)
          │        Single resource type, simple key lookup
          │
          └─ YES → Use Pattern 2 (Ternary Cascade)
                    Conditional ternary based on type attribute
                    Examples: target_type, resource_type, scope_type
                    
Do you need explicit existence check before accessing?
│
├─ NO → Prefer Pattern 1 or 2 with try() (faster)
│
└─ YES → Use Pattern 3 (can() + ternary)
          Only when error handling requires existence check
          Accept 50% performance cost
```

---

## Real-World Example: Chaos Studio Target

### The Challenge
A Chaos Studio Target can point to:
- Storage Accounts (`Microsoft-StorageAccount`)
- Virtual Machines (`Microsoft-VirtualMachine`)
- AKS Clusters (`Microsoft-AKSCluster`)
- Firewalls (`Microsoft-Firewalls`)

The resource type determines which object to lookup.

### The Solution

**Step 1**: Module defines flexible inputs

```hcl
variable "settings" {
  type = object({
    target_resource_id = optional(string)  # Direct ID
    target_resource = optional(object({     # Key-based reference
      key    = string
      lz_key = optional(string)
    }))
    target_type = string  # Determines which object type to fetch
  })
}
```

**Step 2**: Module keeps simple defaults

```hcl
# In module locals - nothing complex
locals {
  target_resource_id = try(var.settings.target_resource_id, null)
}
```

**Step 3**: Aggregator handles conditional resolution

```hcl
# In root aggregator - where combined_objects are available
settings = merge(
  each.value,
  {
    target_resource_id = (
      each.value.target_type == "Microsoft-StorageAccount"
      ? try(local.combined_objects_storage_accounts[...][...].id, null)
      : each.value.target_type == "Microsoft-VirtualMachine"
      ? try(local.combined_objects_virtual_machines[...][...].id, null)
      : ...
    )
  }
)
```

---

## Key Principles

### 1. **Module = Simple**
- Keep resolution logic minimal
- Use `try()` for safe access
- Use `can()` to check existence
- Don't try to resolve all possible resource types

### 2. **Aggregator = Smart**
- Use `local.combined_objects_*` which are fully resolved
- Implement conditional logic based on settings
- Make design decisions about resource types
- Ensure all paths resolve correctly

### 3. **Planning Safety**
- Root aggregator expressions are evaluated BEFORE module planning
- No risk of all-null coalesce errors
- Explicit ordering via `depends_on` if needed
- All values are known at planning time

### 4. **Fallback Order**
```
1. Direct ID (var.settings.target_resource_id)
   ↓
2. Key-based reference (same landing zone)
   ↓
3. Key-based reference (remote landing zone)
   ↓
4. null (error handled by provider or validation)
```

---

## Anti-Patterns to Avoid

### ❌ Don't: Nested try() with coalesce in module

```hcl
# Bad: This fails when all values are null
target_resource_id = coalesce(
  try(var.remote_objects.storage_accounts[...][...].id, null),
  try(var.remote_objects.virtual_machines[...][...].id, null),
  try(var.remote_objects.aks_clusters[...][...].id, null)
)
```

### ❌ Don't: Multiple coalesce calls

```hcl
# Bad: Complex nesting, hard to debug
target_resource_id = coalesce(
  try(..., null),
  coalesce(
    try(..., null),
    try(..., null)
  )
)
```

### ❌ Don't: Accessing remote_objects without lz_key first

```hcl
# Bad: Assumes lz_key exists in target_resource
id = var.remote_objects.storage_accounts[var.settings.target_resource.lz_key][...]
```

---

## Best Practices

### ✅ Do: Explicit lz_key fallback

```hcl
lz_key = try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)
```

### ✅ Do: Use can() for existence checks

```hcl
resource_exists = can(var.remote_objects.storage_accounts[lz_key][resource_key].id)
value = resource_exists ? var.remote_objects.storage_accounts[lz_key][resource_key].id : null
```

### ✅ Do: Handle null in aggregator, not module

```hcl
# In aggregator
target_id = try(local.combined_objects_storage_accounts[lz][key].id, null)

# Pass to module
settings = merge(each.value, { target_resource_id = target_id })
```

### ✅ Do: Document complex resolution

```hcl
# Document why resolution happens in aggregator
settings = merge(
  each.value,
  {
    # IMPORTANT: target_resource_id is resolved here in the aggregator
    # because it depends on target_type which determines the correct
    # combined_objects map to query. Module cannot access combined_objects.
    target_resource_id = (
      each.value.target_type == "Microsoft-StorageAccount" ? ... : ...
    )
  }
)
```

---

## Testing

### Unit Test: Module with pre-resolved ID

```hcl
# Test that module works when ID is provided
module "test_with_direct_id" {
  source = "./modules/chaos_studio/chaos_studio_target"

  settings = {
    target_resource_id = "/subscriptions/.../storageAccounts/test"
    target_type        = "Microsoft-StorageAccount"
  }
}
```

### Integration Test: Full resolution

```hcl
# Test that aggregator resolves correctly
module "test_with_key_reference" {
  source = "./modules/chaos_studio/chaos_studio_target"

  settings = merge(
    {
      target_type = "Microsoft-StorageAccount"
      target_resource = {
        key    = "test_storage"
        lz_key = local.client_config.landingzone_key
      }
    },
    {
      target_resource_id = try(
        local.combined_objects_storage_accounts[local.client_config.landingzone_key]["test_storage"].id,
        null
      )
    }
  )
}
```

---

## References

- **Related Pattern**: Principle 3.5 in copilot-instructions.md
- **Remote Objects**: See `variable.remote_objects` pattern in argument-patterns
- **Combined Objects**: See `locals.combined_objects.tf` for structure
- **Example**: `chaos_studio_chaos_studio_targets.tf` (reference implementation)

---

## Checklist for Implementation

- [ ] Identified module has multi-type resource dependencies
- [ ] Kept module resolution simple (`try()` + `can()`)
- [ ] Added decision logic to aggregator based on resource type
- [ ] Used `local.combined_objects_*` in aggregator, not `var.remote_objects`
- [ ] Added conditional ternary for each resource type
- [ ] Documented why resolution is in aggregator
- [ ] Tested with direct ID (immediate scenario)
- [ ] Tested with key reference (module resolution)
- [ ] Verified no all-null coalesce errors
- [ ] Added comments explaining complex ternary logic

---

## Common Issues & Debugging

### Issue: "Call to function coalesce failed: no non-null arguments"

**Cause**: Trying to resolve all-null value paths in module  
**Fix**: Move resolution to aggregator using conditional ternary  
**Check**: Verify aggregator has access to `local.combined_objects_*`

### Issue: "Reference to undeclared input variable"

**Cause**: Aggregator trying to access `var.remote_objects` that wasn't passed  
**Fix**: Ensure module call includes all `remote_objects` in the definition  
**Check**: Compare with `chaos_studio_chaos_studio_targets.tf` example

### Issue: "The given key does not identify an element"

**Cause**: lz_key or resource_key incorrect in aggregator  
**Fix**: Use `try()` with proper fallbacks around all lookups  
**Check**: Verify keys exist in `local.chaos_studio` configuration
