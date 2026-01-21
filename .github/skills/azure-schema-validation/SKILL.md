---
name: azure-schema-validation
description: Validate Azure Terraform resource schemas using MCP Terraform tools. Use this skill BEFORE implementing or modifying any Azure resource to ensure all attributes are correctly implemented according to the official provider documentation.
---

# Azure Resource Schema Validation (Pattern 0)

**CRITICAL**: This is Pattern 0 - the MANDATORY first step before implementing or modifying any Terraform resource.

## Why This is Mandatory

Validating the resource schema ensures:
- ✅ All required attributes are implemented
- ✅ All optional attributes are handled with proper try() patterns
- ✅ Nested blocks are implemented as dynamic blocks
- ✅ No attributes are missed or incorrectly typed
- ✅ Resource is not deprecated
- ✅ Correct default values are used

**NEVER skip this step**. AI training data may be outdated or incorrect. The Azure provider evolves rapidly.

## Step-by-Step Validation Process

### Step 1: Identify the Resource

Get the full Azure resource type name:
- Format: `azurerm_<resource_name>`
- Example: `azurerm_managed_redis`, `azurerm_container_app`, `azurerm_kubernetes_cluster`

### Step 2: Resolve Provider Documentation ID

Use MCP Terraform tool to get the provider documentation ID:

```
Tool: mcp_terraform_get_provider_details
Parameters:
  namespace: "hashicorp"
  name: "azurerm"  
  provider_doc_id: "resources/<resource_name>"
```

**Example:**
```
mcp_terraform_get_provider_details(
  namespace="hashicorp",
  name="azurerm",
  provider_doc_id="resources/managed_redis"
)
```

### Step 3: Fetch Complete Documentation

Once you have the provider_doc_id, fetch the complete documentation:

**This will return:**
- Full resource schema
- All arguments (required and optional)
- Nested block structures
- Timeouts configuration
- Import information
- Deprecation status

### Step 4: Extract Schema Information

From the documentation, extract:

#### A. Required Arguments

List all required arguments that MUST be present:
```hcl
# Example for azurerm_managed_redis
resource_group_name = var.settings.resource_group_name  # Required, no try()
location            = var.settings.location             # Required, no try()
sku_name            = var.settings.sku_name            # Required, no try()
```

#### B. Optional Arguments

List all optional arguments with proper try() patterns:
```hcl
# Arguments with no default (defaults to null)
family_name = try(var.settings.family_name, null)
capacity    = try(var.settings.capacity, null)

# Arguments with provider defaults (use same default)
minimum_tls_version = try(var.settings.minimum_tls_version, "1.2")
public_network_access_enabled = try(var.settings.public_network_access_enabled, true)
```

#### C. Nested Blocks

Identify blocks that should be implemented as dynamic blocks:
```hcl
# Single optional block
dynamic "identity" {
  for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
  
  content {
    type         = identity.value.type
    identity_ids = try(identity.value.identity_ids, null)
  }
}

# Multiple blocks (list)
dynamic "access_policy" {
  for_each = try(var.settings.access_policies, [])
  
  content {
    tenant_id = access_policy.value.tenant_id
    object_id = access_policy.value.object_id
  }
}

# Multiple blocks (map - preferred for stable keys)
dynamic "zone_mapping" {
  for_each = try(var.settings.zone_mappings, {})
  
  content {
    zone_id   = zone_mapping.value.zone_id
    subnet_id = zone_mapping.value.subnet_id
  }
}
```

#### D. Timeouts Block

Always implement timeouts block:
```hcl
dynamic "timeouts" {
  for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
  
  content {
    create = try(timeouts.value.create, null)
    read   = try(timeouts.value.read, null)
    update = try(timeouts.value.update, null)
    delete = try(timeouts.value.delete, null)
  }
}
```

### Step 5: Check Deprecation Status

**CRITICAL**: If the documentation shows the resource is deprecated:
- ❌ DO NOT implement this resource
- ❌ DO NOT extend this resource
- ✅ Use the replacement resource mentioned in the deprecation notice
- ✅ Inform the user about the deprecation and the correct alternative

**Example:**
```
DEPRECATED: azurerm_redis_cache is deprecated. Use azurerm_managed_redis instead.
```

### Step 6: Document Validated Schema

Create a validation checklist for the resource:

```markdown
## Schema Validation for azurerm_<resource_name>

### Required Arguments
- [ ] argument1 - type: string
- [ ] argument2 - type: number

### Optional Arguments
- [ ] optional1 - type: string, default: null
- [ ] optional2 - type: bool, default: true
- [ ] optional3 - type: list(string), default: []

### Nested Blocks
- [ ] block1 (optional, single)
  - [ ] attribute1 - type: string
  - [ ] attribute2 - type: number
- [ ] block2 (optional, multiple)
  - [ ] attribute1 - type: string

### Timeouts
- [ ] create
- [ ] read
- [ ] update
- [ ] delete

### Deprecation Status
- [ ] NOT deprecated ✅
- [ ] OR deprecated → use <replacement_resource> instead
```

## Implementation Guidelines

After validating the schema, implement the resource following these patterns:

### Required Arguments Pattern
```hcl
# No try() - must be provided
required_argument = var.settings.required_argument
```

### Optional Arguments Pattern
```hcl
# No default value in provider
optional_argument = try(var.settings.optional_argument, null)

# Has default value in provider (match the default)
optional_with_default = try(var.settings.optional_with_default, "provider_default_value")
```

### Boolean Arguments Pattern
```hcl
# Explicitly default to provider default
enabled = try(var.settings.enabled, true)  # If provider defaults to true
disabled = try(var.settings.disabled, false)  # If provider defaults to false
```

### List Arguments Pattern
```hcl
# Empty list as default
allowed_values = try(var.settings.allowed_values, [])

# Null as default if provider doesn't require list
optional_list = try(var.settings.optional_list, null)
```

### Map Arguments Pattern
```hcl
# Empty map as default
configurations = try(var.settings.configurations, {})
```

### Standard Attributes Pattern
```hcl
# Always use locals for these
location            = local.location
resource_group_name = local.resource_group_name
tags                = merge(local.tags, try(var.settings.tags, null))
```

## Variables.tf Type Definition

After schema validation, define the variable with complete type specification:

```hcl
variable "settings" {
  description = <<DESCRIPTION
    Settings object for azurerm_<resource_name>. Configuration attributes:
    
    Required:
      - required_arg1 - (string) Description from Azure docs
      - required_arg2 - (number) Description from Azure docs
    
    Optional:
      - optional_arg1 - (string) Description. Defaults to null.
      - optional_arg2 - (bool) Description. Defaults to true.
      - nested_block - (object) Optional nested configuration:
          - nested_attr1 - (string) Description
          - nested_attr2 - (number) Description
    
    DESCRIPTION
  
  type = object({
    # Required arguments
    required_arg1 = string
    required_arg2 = number
    
    # Optional arguments
    optional_arg1 = optional(string)
    optional_arg2 = optional(bool)
    
    # Optional nested block
    nested_block = optional(object({
      nested_attr1 = string
      nested_attr2 = number
    }))
    
    # Standard optional attributes
    location            = optional(string)
    resource_group_name = optional(string)
    tags                = optional(map(string))
    
    # Timeouts
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  
  validation {
    condition = length(setsubtract(keys(var.settings), [
      "required_arg1", "required_arg2",
      "optional_arg1", "optional_arg2",
      "nested_block",
      "location", "resource_group_name", "tags",
      "timeouts"
    ])) == 0
    error_message = "Unsupported attributes detected in settings. See variable description for allowed attributes."
  }
}
```

## Common Validation Pitfalls

### ❌ Mistake 1: Skipping Validation
```hcl
# ❌ WRONG - Guessing attributes
resource "azurerm_resource" "example" {
  name     = var.settings.name
  location = var.settings.location
  # Missing many required and optional attributes!
}
```

### ❌ Mistake 2: Incorrect Default Values
```hcl
# ❌ WRONG - Using wrong default
enabled = try(var.settings.enabled, false)  # Provider default is true!

# ✅ CORRECT - Match provider default
enabled = try(var.settings.enabled, true)
```

### ❌ Mistake 3: Missing Nested Blocks
```hcl
# ❌ WRONG - Not implementing nested blocks from schema
resource "azurerm_resource" "example" {
  name = var.settings.name
  # Missing identity block that exists in schema!
}

# ✅ CORRECT - Implement all nested blocks
resource "azurerm_resource" "example" {
  name = var.settings.name
  
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
    content {
      type = identity.value.type
    }
  }
}
```

### ❌ Mistake 4: Not Checking Deprecation
```hcl
# ❌ WRONG - Implementing deprecated resource
resource "azurerm_redis_cache" "example" {
  # This resource is DEPRECATED!
}

# ✅ CORRECT - Use replacement
resource "azurerm_managed_redis" "example" {
  # Use the current, non-deprecated resource
}
```

## Quick Reference: MCP Terraform Tools

### Get Provider Details
```
Tool: mcp_terraform_get_provider_details
Parameters:
  namespace: "hashicorp"
  name: "azurerm"
  provider_doc_id: "resources/<resource_name>"
```

### Search for Resources
```
Tool: mcp_terraform_search_providers
Parameters:
  query: "<resource_name> OR <service_name>"
```

### Get Provider Capabilities
```
Tool: mcp_terraform_get_provider_capabilities
Parameters:
  namespace: "hashicorp"
  name: "azurerm"
```

## Validation Checklist

Before implementing or modifying a resource:

- [ ] Identified full resource type name (azurerm_*)
- [ ] Fetched provider documentation using MCP Terraform tools
- [ ] Verified resource is NOT deprecated
- [ ] Extracted all required arguments
- [ ] Extracted all optional arguments with defaults
- [ ] Identified all nested blocks
- [ ] Documented timeouts support
- [ ] Created complete type definition in variables.tf
- [ ] Implemented all arguments in resource block
- [ ] Added dynamic blocks for nested configuration
- [ ] Added timeouts block
- [ ] Ready to proceed with implementation

## When to Re-validate

Re-run schema validation:
- When Azure provider version updates
- When adding new attributes to existing resource
- When users report missing attributes
- When extending module with new features
- Annually for actively maintained modules

## Remember

**Pattern 0 is MANDATORY**. Never skip schema validation. Your module is only as good as its adherence to the official Azure provider schema.

If validation reveals the resource is deprecated, STOP and use the replacement resource instead.
