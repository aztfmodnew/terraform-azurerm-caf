# Dependency Resolution - Remote Objects Pattern

**Last Updated**: January 2026  
**Context**: Implementing remote_objects pattern for complex multi-type dependencies  

---

## The Pattern

### Scenario
Creating a `azurerm_chaos_studio_target` module that can target:
- Storage Accounts
- Virtual Machines  
- AKS Clusters
- Firewalls

The resource type is configurable (via `target_type`), and we want to support both direct IDs and key-based references.

---

## The Anti-Pattern ❌

### The Code (INCORRECT - Don't do this)

**File: `modules/chaos_studio/chaos_studio_target/chaos_studio_target.tf`**

```hcl
resource "azurerm_chaos_studio_target" "target" {
  location = local.location
  target_resource_id = coalesce(
    try(var.settings.target_resource_id, null),
    try(var.remote_objects.storage_accounts[try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)][try(var.settings.target_resource.key, var.settings.target_resource_key)].id, null),
    try(var.remote_objects.virtual_machines[try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)][try(var.settings.target_resource.key, var.settings.target_resource_key)].id, null),
    try(var.remote_objects.aks_clusters[try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)][try(var.settings.target_resource.key, var.settings.target_resource_key)].id, null),
    try(var.remote_objects.azurerm_firewalls[try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)][try(var.settings.target_resource.key, var.settings.target_resource_key)].id, null)
  )
  target_type = var.settings.target_type
  # ... rest of config
}
```

### The Error

```
Error: Error in function call

  on ../modules/chaos_studio/chaos_studio_target/chaos_studio_target.tf line 3, in resource "azurerm_chaos_studio_target" "target":
   3:   target_resource_id = coalesce(
   ...
  
  Call to function "coalesce" failed: no non-null, non-empty-string arguments.
  ├────────────────
  │ while calling coalesce(vals...)
  │ var.client_config.landingzone_key is "examples"
  │ var.remote_objects.aks_clusters is map of object with 1 element
  │ var.remote_objects.azurerm_firewalls is map of object with 1 element
  │ var.remote_objects.storage_accounts is map of object with 1 element
  │ var.remote_objects.virtual_machines is map of object with 1 element
  │ var.settings is object with 4 attributes
  │ var.settings.target_resource.key is "test_storage"
  │ var.settings.target_resource.lz_key is null
  │ var.settings.target_resource_id is null
  │
  │ Call to function "coalesce" failed: no non-null, non-empty-string arguments.
```

### Why It Fails

1. **All try() might return null**: If the resource isn't found in any collection, ALL `try()` expressions return `null`
2. **coalesce() requires at least one non-null**: With all arguments as `null`, the function throws an error
3. **Complexity in resource block**: Hard to read and maintain with deeply nested expressions

### Root Cause

- ❌ Multiple `try()` expressions in `coalesce()` that can all fail
- ❌ No conditional logic based on `target_type` - checks all resource types
- ❌ Resolution logic mixed with resource declaration

---

## The Correct Pattern ✅

### Solution 1: Ternary Cascade (Multi-Type Conditional)

**File: `modules/chaos_studio/chaos_studio_target/locals.tf`**

```hcl
locals {
  module_tag = {
    "chaos_studio/chaos_studio_target" = basename(abspath(path.module))
  }
  tags = merge(var.base_tags, local.module_tag, try(var.settings.tags, null))

  location = coalesce(
    try(var.settings.location, null),
    var.location,
    var.resource_group.location
  )

  resource_group_name = coalesce(
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][try(var.settings.resource_group.key, var.settings.resource_group_key)].name, null)
  )

  # CRITICAL: Resolution based on target_type
  lz_key         = try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)
  resource_key   = try(var.settings.target_resource.key, var.settings.target_resource_key)
  
  # Ternary cascade with explicit type checks
  target_resource_id = (
    var.settings.target_resource_id != null ? var.settings.target_resource_id :
    var.settings.target_type == "Microsoft-StorageAccount" ? try(var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-VirtualMachine" ? try(var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-AKSCluster" ? try(var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id, null) :
    var.settings.target_type == "Microsoft-Firewalls" ? try(var.remote_objects.azurerm_firewalls[local.lz_key][local.resource_key].id, null) :
    null  # Clean fallback
  )
}
```

**File: `modules/chaos_studio/chaos_studio_target/chaos_studio_target.tf`**

```hcl
resource "azurerm_chaos_studio_target" "target" {
  location           = local.location
  target_resource_id = local.target_resource_id  # ← Simple reference!
  target_type        = var.settings.target_type

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}
```

**File: `chaos_studio_chaos_studio_targets.tf` (ROOT AGGREGATOR)**

```hcl
module "chaos_studio_targets" {
  source   = "./modules/chaos_studio/chaos_studio_target"
  for_each = local.chaos_studio.chaos_studio_targets

  depends_on = [
    module.storage_accounts,
    module.virtual_machines,
    module.aks_clusters,
    module.azurerm_firewalls
  ]

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  
  # Pass settings directly - NO resolution here
  settings = each.value

  # Pass ALL dependencies
  remote_objects = {
    resource_groups   = local.combined_objects_resource_groups
    storage_accounts  = local.combined_objects_storage_accounts
    virtual_machines  = local.combined_objects_virtual_machines
    aks_clusters      = local.combined_objects_aks_clusters
    azurerm_firewalls = local.combined_objects_azurerm_firewalls
  }
}
```

### Solution 2: Using can() for Existence Checks (Alternative)

**When to use**: When you need explicit existence validation before accessing resources.

```hcl
# In locals.tf
locals {
  lz_key       = try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)
  resource_key = try(var.settings.target_resource.key, var.settings.target_resource_key)
  
  # Check existence first (2 evaluations - 50% slower than try())
  storage_account_id = can(var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id) 
    ? var.remote_objects.storage_accounts[local.lz_key][local.resource_key].id 
    : null
  virtual_machine_id = can(var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id) 
    ? var.remote_objects.virtual_machines[local.lz_key][local.resource_key].id 
    : null
  aks_cluster_id = can(var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id) 
    ? var.remote_objects.aks_clusters[local.lz_key][local.resource_key].id 
    : null
    
  # Then use ternary based on type
  target_resource_id = (
    var.settings.target_resource_id != null ? var.settings.target_resource_id :
    var.settings.target_type == "Microsoft-StorageAccount" ? local.storage_account_id :
    var.settings.target_type == "Microsoft-VirtualMachine" ? local.virtual_machine_id :
    var.settings.target_type == "Microsoft-AKSCluster" ? local.aks_cluster_id :
    null
  )
}
```

**Trade-offs**:
- ✅ Explicit existence checks (clearer intent)
- ❌ 50% slower (2 evaluations: can() check + ternary access)
- Use only when error handling requires existence validation

---

## Key Differences - Pattern Selection

| Aspect | Anti-Pattern ❌ | Ternary Cascade ✅ | can() Pattern ✅ |
|--------|----------------|-------------------|------------------|
| **Where logic lives** | Resource block | Module locals | Module locals |
| **Resolution clarity** | All types checked | Based on target_type | Based on target_type |
| **coalesce() safety** | All null → Error | Never all null | Never all null |
| **Readability** | Complex nested try() | Clear conditional | Explicit checks |
| **Performance** | N/A | Fastest (1 eval) | Slower (2 evals) |
| **Maintainability** | Hard to extend | Easy: add branch | Easy: add check |
| **Error messages** | Cryptic coalesce | Clear type mismatch | Clear validation |

---

## Implementation Best Practices

### 1. Choose the Right Pattern

```
Does resource accept multiple types?
│
├─ NO → Use simple coalesce (Pattern 1 in main docs)
│
└─ YES → Is resolution based on a type attribute?
          │
          ├─ YES → Use ternary cascade (Solution 1)
          │        Best performance, clear intent
          │
          └─ NO → Use can() checks (Solution 2)
                   Only if explicit validation needed
```

### 2. Performance Guidelines

- **Ternary cascade**: 1 evaluation per branch → Fastest
- **can() + ternary**: 2 evaluations per type → 50% slower
- **Prefer ternary cascade** unless explicit existence check is required

### 3. Code Organization

✅ **DO**:
- Resolve ALL resource IDs in `locals.tf`
- Reference locals in resource blocks: `attribute_id = local.resource_id`
- Document why ternary cascade is used (multi-type conditional)
- Use clean `null` fallback (no hardcoded IDs)

❌ **DON'T**:
- Inline coalesce in resource blocks
- Use multiple try() in coalesce that all might fail
- Hardcode fallback IDs
- Resolve in aggregator (pass settings directly)

## Lessons Learned

### 1. Understand Terraform's Evaluation Order

- **Module locals**: Evaluated when module is instantiated
- **var.remote_objects**: Available immediately (passed by aggregator)
- **Resolution timing**: Module locals have full access to var.remote_objects

### 2. Use appropriate patterns for each situation

| Scenario | Pattern | Performance |
|----------|---------|-------------|
| Single resource type | `coalesce()` with `try()` | Fast (1 eval) |
| Multi-type conditional | Ternary cascade with `try()` | Fast (1 eval per branch) |
| Explicit existence check | `can()` + ternary | Slower (2 evals) |

### 3. When coalesce fails: Use ternary cascade

- If `coalesce()` might receive all null → Use ternary with explicit checks
- Condition on type attribute (target_type, resource_type, etc.)
- Each branch resolves only one resource type
- Clean `null` fallback at end

### 4. Document pattern selection

```hcl
# Comment explaining WHY ternary cascade is used
locals {
  # PATTERN: Multi-type conditional resolution
  # target_resource_id can be Storage/VM/AKS based on target_type
  # Using ternary cascade to avoid coalesce error when all try() return null
  target_resource_id = (
    var.settings.target_resource_id != null ? var.settings.target_resource_id :
    var.settings.target_type == "Microsoft-StorageAccount" ? ... : ...
  )
}
```

---

## Testing Scenarios

### Test 1: Direct ID (No Resolution Needed)

```hcl
# This always works, regardless of pattern
settings = {
  target_type = "Microsoft-StorageAccount"
  target_resource_id = "/subscriptions/.../storageAccounts/test"  # Direct ID
}
```

**Result**: ✅ Works with all patterns

### Test 2: Key-based Reference (Pattern Matters)

```hcl
# Requires proper pattern implementation
settings = {
  target_type = "Microsoft-StorageAccount"
  target_resource = {
    key = "test_storage"  # Must be resolved to ID
  }
}
```

**Result**: 
- ❌ Anti-pattern: coalesce error
- ✅ Ternary cascade: ID resolved correctly
- ✅ can() pattern: ID resolved with validation

### Test 3: Cross-Landing-Zone Reference

```hcl
# Advanced scenario
settings = {
  target_type = "Microsoft-StorageAccount"
  target_resource = {
    key    = "test_storage"
    lz_key = "remote_lz"  # Reference from different LZ
  }
}
```

**Result**:
- ❌ Anti-pattern: Complex nested try() still fails
- ✅ Both correct patterns: Handle cleanly with lz_key fallback

---

## Applicability to Other Modules

This pattern applies to any module where:

1. ✅ Module can reference multiple resource types
2. ✅ Resolution logic depends on a configuration value (type attribute)
3. ✅ Simple `coalesce()` with multiple `try()` isn't sufficient

### Modules that should use this pattern

- **Multi-target resources**: Chaos Studio, Monitor alerts, Policy assignments
- **Flexible scope**: Resources that can target subscription/resource group/resource
- **Dynamic backends**: Storage, logging, or compute backend selection
- **Security principals**: Resources supporting user/group/service principal/managed identity

---

## Implementation Checklist

- [ ] Identified the problem: coalesce with all-null during planning
- [ ] Understood conditional logic: Based on type attribute (target_type, etc.)
- [ ] Selected pattern: Ternary cascade (preferred) or can() checks
- [ ] Implemented in module locals: ALL resolution logic
- [ ] Kept resource block simple: Reference local variable
- [ ] Updated aggregator: Pass settings directly + remote_objects
- [ ] Tested direct ID path: Still works
- [ ] Tested key reference path: Now works
- [ ] Added depends_on: Explicit ordering if needed
- [ ] Documented pattern choice: Comments for future maintainers
- [ ] Verified error messages: Clearer than before
- [ ] No hardcoded fallbacks: Clean null at end
