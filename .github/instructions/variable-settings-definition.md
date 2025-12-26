---
applyTo: "modules/**/variables.tf"
---

# Settings Variable Definition Standards

## Overview

Every module MUST define the `settings` variable with explicit type definition, comprehensive documentation, and validation. The `settings` variable is the primary input for module configuration and must be treated as a first-class citizen in variable design.

## Required Structure

### Complete Example

```hcl
variable "settings" {
  description = <<DESCRIPTION
    Settings object for the Managed Redis instance. This object defines the configuration for Azure Managed Redis deployment.
    The settings object supports the following attributes:
      - name - (Required) The name which should be used for this Managed Redis instance. Changing this forces a new Managed Redis instance to be created.
      - resource_group_key - (Optional) The key of the resource group to deploy the resource in.
      - sku_name - (Required) The SKU name for the Managed Redis instance. Possible values are Balanced_B0 through Balanced_B1000, ComputeOptimized_X3 through ComputeOptimized_X700, FlashOptimized_A250 through FlashOptimized_A4500, MemoryOptimized_M10 through MemoryOptimized_M700.
      - high_availability_enabled - (Optional) Whether to enable high availability. Defaults to true. Changing this forces a new resource to be created.
      - identity - (Optional) An identity block specifying system-assigned or user-assigned managed identities.
      - tags - (Optional) A mapping of tags which should be assigned to the resource.
    DESCRIPTION
  type = object({
    name                          = string
    resource_group_key            = optional(string)
    sku_name                      = string
    high_availability_enabled     = optional(bool)
    identity                      = optional(any)
    tags                          = optional(map(string))
    azurecaf_resource_type        = optional(string)
  })
  validation {
    condition = length(setsubtract(
      keys(var.settings),
      [
        "name",
        "resource_group_key",
        "sku_name",
        "high_availability_enabled",
        "identity",
        "tags",
        "azurecaf_resource_type"
      ]
    )) == 0
    error_message = format("The following attributes are not supported within settings: %s. Allowed attributes are: name, resource_group_key, sku_name, high_availability_enabled, identity, tags, azurecaf_resource_type.",
      join(", ",
        setsubtract(
          keys(var.settings),
          [
            "name",
            "resource_group_key",
            "sku_name",
            "high_availability_enabled",
            "identity",
            "tags",
            "azurecaf_resource_type"
          ]
        )
      )
    )
  }
}
```

## Key Requirements

### 1. Type Definition

**MUST**: Use `object()` with all supported attributes explicitly listed
**MUST NOT**: Use generic `any` type without structure

```hcl
# ✅ CORRECT
type = object({
  name       = string
  enabled    = optional(bool)
  tags       = optional(map(string))
})

# ❌ WRONG
type = any
```

### 2. Attribute Types

Each attribute must have explicit type specification:

- **Required attributes**: Use base types directly
  - `name = string`
  - `count = number`
  - `enabled = bool`
  - `config = any`

- **Optional attributes**: Use `optional()` wrapper
  - `description = optional(string)`
  - `tags = optional(map(string))`
  - `settings = optional(any)`

### 3. Documentation (MANDATORY)

Use `<<DESCRIPTION ... DESCRIPTION` heredoc syntax to document:

**Must Include:**

- Purpose of the settings object
- Complete list of all attributes
- Type and whether each is required or optional
- Constraints and valid values from Azure provider documentation
- Default values for optional attributes
- Examples or references where helpful

```hcl
description = <<DESCRIPTION
  Settings object for the [Resource Name]. Configuration attributes:
    - name - (Required) Name of the resource. Changing forces new resource.
    - enabled - (Optional) Whether the resource is enabled. Defaults to true.
    - config - (Optional) Nested configuration object.
    - tags - (Optional) Tags to assign to the resource.
  DESCRIPTION
```

### 4. Validation Block (MANDATORY)

Always include validation that rejects unsupported attributes:

```hcl
validation {
  condition = length(setsubtract(
    keys(var.settings),
    ["name", "enabled", "config", "tags"]
  )) == 0
  error_message = format("Unsupported settings attributes: %s. Allowed: name, enabled, config, tags.",
    join(", ",
      setsubtract(
        keys(var.settings),
        ["name", "enabled", "config", "tags"]
      )
    )
  )
}
```

**Why validation is critical:**

- Catches typos early (e.g., `enabld` instead of `enabled`)
- Provides clear error messages to users
- Prevents silent failures from misspelled attributes

### 5. Standard Attributes

All modules should support these standard attributes where applicable:

- `name` - (Required) Resource name
- `resource_group_key` - (Optional) RG reference key
- `tags` - (Optional) Resource tags
- `azurecaf_resource_type` - (Optional) Override CAF resource type for naming

## Testing Your Variable Definition

Run mock tests to verify the variable definition is correct:

```bash
cd examples
terraform init -upgrade
terraform test -test-directory=./tests/mock -var-file=./category/service/100-example/configuration.tfvars -verbose
```

**Common validation errors:**

- "Reference to undeclared input variable" → Check variable names match throughout module
- "Type mismatch" → Verify attribute types in object definition match usage

## Examples in Repository

Reference these modules for correct implementations:

- `modules/cache/managed_redis` - Complete example with identity, optional blocks
- Look for modules with comprehensive object type definitions

## Do's and Don'ts

✅ **DO:**

- Define all attributes in `object()`
- Use `optional()` for non-required attributes
- Include comprehensive DESCRIPTION documentation
- Add validation block to catch unsupported attributes
- Update settings variable when adding new attributes

❌ **DON'T:**

- Use generic `type = any` without structure
- Omit documentation on attributes
- Add validation but not documentation
- Change attribute types without updating examples
- Use `type = any` and claim type safety
