---
name: module-creation
description: Complete workflow for creating a new Azure CAF Terraform module from scratch. Use this skill when the user explicitly asks to create a new module for an Azure resource type.
---

# Azure CAF Module Creation Workflow

Follow this systematic workflow when creating a new Terraform module for Azure resources in the CAF framework.

## Pre-requisites Check

Before starting, verify:
- Azure resource type name (e.g., `azurerm_managed_redis`, `azurerm_container_app`)
- Whether the resource is deprecated in the Azure provider documentation
- Category for the module (e.g., `cache`, `cognitive_services`, `compute`)
- **CRITICAL: Check for related resources in the same service**
  - Search Terraform docs for resources with the same prefix
  - Example: `azurerm_chaos_studio_*` → 3 resources (target, capability, experiment)
  - Example: `azurerm_container_app_*` → 3 resources (app, environment, job)
  - **If related resources exist, you MUST implement ALL of them as a set**

## Step-by-Step Workflow

### Step 0: Validate Resource Schema (MANDATORY)

**CRITICAL**: This step is NON-NEGOTIABLE. Never skip it.

Use MCP Terraform tools to get complete resource documentation:

```bash
# 1. Get provider doc ID
mcp_terraform_resolveProviderDocID(namespace="hashicorp", name="azurerm", resource_type="<resource_name>")

# 2. Fetch complete documentation
mcp_terraform_getProviderDocs(provider_doc_id="<id_from_step_1>")
```

**What to extract:**
- All required attributes
- All optional attributes (use `try(var.settings.attribute, null)`)
- All nested blocks (implement as dynamic blocks)
- Timeouts block support
- Deprecation status (if deprecated, STOP and use replacement resource)
- **CRITICAL**: Identify ALL attributes that accept Azure resource IDs:
  - Attributes ending in `_id` (e.g., `subnet_id`, `service_plan_id`, `target_resource_id`)
  - Attributes named `scope` or containing `scope`
  - Attributes referencing other resources (e.g., `parent_id`, `workspace_id`)
  - Document which resource types they can reference (check Azure docs)

**DO NOT PROCEED** until you have validated ALL attributes against the schema.

### Step 1: Create Directory Structure

Create the module directory following the standard two-level structure:

```
modules/
└── <category_name>/
    └── <module_name>/
        ├── providers.tf
        ├── variables.tf
        ├── locals.tf
        ├── azurecaf_name.tf          # If resource has a name
        ├── <module_name>.tf           # Main resource
        ├── diagnostics.tf             # If service supports diagnostics
        ├── private_endpoint.tf        # If service supports private endpoints
        ├── managed_identities.tf      # If service supports managed identity
        └── outputs.tf
```

**Module name convention**: Remove provider prefix (e.g., `container_app` from `azurerm_container_app`)

### Step 2: Create providers.tf

```hcl
terraform {
  required_providers {
    azurecaf = {
      source = "aztfmodnew/azurecaf"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    # Add azapi only if needed for preview features
  }
}
```

### Step 3: Create variables.tf

**CRITICAL**: Use generic `settings` variable name, NOT resource-specific names.

```hcl
variable "global_settings" {
  description = "Global settings object (required)"
}

variable "client_config" {
  description = "Client configuration object (required)"
}

variable "settings" {
  description = <<DESCRIPTION
    Settings object for the <resource_type>. Configuration attributes:
      - name - (Required) Name of the resource
      - <attribute> - (Required/Optional) <Description from Azure docs>
      [List ALL attributes from Step 0 validation]
    DESCRIPTION
  type = object({
    name = string
    # Add all other attributes with proper types
    # Use optional() for optional attributes
  })
  validation {
    condition     = length(setsubtract(keys(var.settings), ["name", "attribute1", "attribute2"])) == 0
    error_message = "Unsupported attributes in settings. Allowed: name, attribute1, attribute2."
  }
}

variable "resource_group" {
  description = "Resource group object"
  default     = null
}

variable "resource_groups" {
  description = "Resource groups object"
  default     = {}
}

variable "location" {
  description = "Location for the resource"
  default     = null
}

variable "base_tags" {
  description = "Base tags for the module to be inherited from the calling module"
  type        = map(any)
  default     = {}
}

variable "remote_objects" {
  description = "Remote objects for dependency resolution"
  default = {
    resource_groups = {}
    # Add other dependencies as needed
    # CRITICAL: For ANY resource attribute accepting Azure resource IDs,
    # add the corresponding resource type here:
    # - If resource has subnet_id -> add vnets, virtual_subnets
    # - If resource has service_plan_id -> add service_plans, app_service_plans
    # - If resource has target_resource_id -> add storage_accounts, virtual_machines, aks_clusters
    # - If resource has scope_resource_id -> add resource_groups, subscriptions
    # - If resource has identity block -> add managed_identities
  }
}

# Add if service supports diagnostics
variable "diagnostics" {
  description = "Diagnostics configuration object"
  default     = null
}

# Add if service supports private endpoints
variable "private_endpoints" {
  description = "Private endpoints configuration"
  default     = {}
}

variable "private_dns" {
  description = "Private DNS zones configuration"
  default     = {}
}

variable "vnets" {
  description = "Virtual networks object"
  default     = {}
}

variable "virtual_subnets" {
  description = "Virtual subnets object"
  default     = {}
}
```

### Step 4: Create locals.tf

**Standard locals pattern (MANDATORY):**

```hcl
locals {
  module_tag = {
    "<category>/<module_name>" = basename(abspath(path.module))
  }

  tags = merge(var.base_tags, local.module_tag, try(var.settings.tags, null))

  location = coalesce(
    try(var.settings.location, null),
    try(var.location, null),
    try(var.resource_group.location, null),
    try(var.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][try(var.settings.resource_group.key, var.settings.resource_group_key)].location, null)
  )

  resource_group_name = coalesce(
    try(var.settings.resource_group_name, null),
    try(var.resource_group.name, null),
    try(var.resource_groups[try(var.settings.resource_group.lz_key, var.client_config.landingzone_key)][try(var.settings.resource_group.key, var.settings.resource_group_key)].name, null)
  )
  
  # CRITICAL: Resolve ALL resource ID dependencies here
  # Pattern 1: Single resource type (most common)
  lz_key       = try(var.settings.subnet.lz_key, var.client_config.landingzone_key)
  resource_key = try(var.settings.subnet.key, var.settings.subnet_key)
  
  subnet_id = coalesce(
    try(var.settings.subnet_id, null),  # Direct ID
    try(var.remote_objects.virtual_subnets[local.lz_key][local.resource_key].id, null)  # Key-based
  )
  
  # Pattern 2: Multi-type conditional (if resource accepts different types)
  # Example: target_resource_id can be Storage/VM/AKS based on target_type
  target_lz_key  = try(var.settings.target_resource.lz_key, var.client_config.landingzone_key)
  target_key     = try(var.settings.target_resource.key, var.settings.target_resource_key)
  
  target_resource_id = (
    var.settings.target_resource_id != null ? var.settings.target_resource_id :
    var.settings.target_type == "Microsoft-StorageAccount" ? try(var.remote_objects.storage_accounts[local.target_lz_key][local.target_key].id, null) :
    var.settings.target_type == "Microsoft-VirtualMachine" ? try(var.remote_objects.virtual_machines[local.target_lz_key][local.target_key].id, null) :
    null  # Clean fallback
  )
}
```

**Key Points**:
- ✅ ALL resource ID resolution happens in locals, NOT in resource blocks
- ✅ Use Pattern 1 (coalesce) for single resource type
- ✅ Use Pattern 2 (ternary cascade) for multi-type conditional
- ✅ Never hardcode fallback IDs - use `null`
- ❌ Never resolve in aggregator - always in module locals

### Step 5: Create azurecaf_name.tf (if resource has name)

```hcl
resource "azurecaf_name" "<module_name>" {
  name          = var.settings.name
  resource_type = "<caf_resource_type>"  # e.g., "azurerm_redis_cache"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, null)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}
```

### Step 6: Create main resource file (<module_name>.tf)

Implement ALL attributes validated in Step 0:

```hcl
resource "azurerm_<resource_type>" "<module_name>" {
  name                = azurecaf_name.<module_name>.result
  location            = local.location
  resource_group_name = local.resource_group_name
  
  # Required attributes - no try()
  required_attribute = var.settings.required_attribute
  
  # Optional attributes - use try() with appropriate defaults
  optional_attribute = try(var.settings.optional_attribute, null)
  
  # Attributes with default values
  attribute_with_default = try(var.settings.attribute_with_default, "default_value")
  
  # CRITICAL: Resource ID dependencies - resolve in locals.tf
  # Reference the local variable here
  subnet_id = local.subnet_id
  service_plan_id = local.service_plan_id
  
  # Dynamic blocks for optional nested configuration
  dynamic "optional_block" {
    for_each = try(var.settings.optional_block, null) == null ? [] : [var.settings.optional_block]

    content {
      attribute = optional_block.value.attribute
    }
  }
  
  # Identity block (if supported)
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = identity.value.type
      identity_ids = local.managed_identities
    }
  }
  
  tags = merge(local.tags, try(var.settings.tags, null))
  
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

**IMPORTANT**: All resource ID resolution MUST happen in `locals.tf`, not directly in the resource block. This allows for:
- Pattern 1 (Simple): Single resource type with coalesce
- Pattern 2 (Conditional): Multi-type with ternary cascade
- Pattern 3 (Safe check): Using can() for existence validation
  
  # Dynamic blocks for optional nested configuration
  dynamic "optional_block" {
    for_each = try(var.settings.optional_block, null) == null ? [] : [var.settings.optional_block]
    
    content {
      attribute = optional_block.value.attribute
    }
  }
  
  # Identity block (if supported)
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
    
    content {
      type         = var.settings.identity.type
      identity_ids = contains(["userassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
    }
  }
  
  tags = merge(local.tags, try(var.settings.tags, null))
  
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
```

### Step 7: Create diagnostics.tf (if supported)

**Check Azure documentation** to confirm service supports diagnostic settings.

```hcl
module "diagnostics" {
  source   = "../../diagnostics"
  for_each = try(var.settings.diagnostic_profiles, {})

  resource_id       = azurerm_<resource_type>.<module_name>.id
  resource_location = azurerm_<resource_type>.<module_name>.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

### Step 8: Create private_endpoint.tf (if supported)

**Check Azure documentation** to confirm service supports private endpoints.

```hcl
module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_<resource_type>.<module_name>.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id = coalesce(
    try(each.value.subnet_id, null),
    try(var.virtual_subnets[try(each.value.subnet.lz_key, var.client_config.landingzone_key)][each.value.subnet.key].id, null)
  )
  settings                     = each.value
  private_dns                  = var.private_dns
  base_tags                    = local.tags
  client_config                = var.client_config
  subresource_names            = try(each.value.subresource_names, ["<default_subresource>"])
}
```

### Step 9: Create managed_identities.tf (if identity supported)

```hcl
#
# Managed identities from remote state
#

locals {
  managed_local_identities = flatten([
    for managed_identity_key in try(var.settings.identity.managed_identity_keys, []) : [
      var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
    ]
  ])

  managed_remote_identities = flatten([
    for lz_key, value in try(var.settings.identity.remote, []) : [
      for managed_identity_key in value.managed_identity_keys : [
        var.remote_objects.managed_identities[lz_key][managed_identity_key].id
      ]
    ]
  ])

  managed_identities = concat(local.managed_local_identities, local.managed_remote_identities)
}
```

### Step 10: Create outputs.tf

```hcl
output "id" {
  description = "Resource ID of the <resource_type>"
  value       = azurerm_<resource_type>.<module_name>.id
}

output "name" {
  description = "Name of the <resource_type>"
  value       = azurerm_<resource_type>.<module_name>.name
}

output "location" {
  description = "Location of the <resource_type>"
  value       = azurerm_<resource_type>.<module_name>.location
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_<resource_type>.<module_name>.resource_group_name
}

# Add other important outputs
```

### Step 11: Identify and Document Dependencies (MANDATORY)

Before creating the root aggregator file, analyze ALL resource ID dependencies:

**1. Review the resource schema from Step 0:**
   - List every attribute ending in `_id`
   - List every attribute that references another resource
   - Check Azure documentation for which resource types are accepted

**2. Map dependencies to CAF module names:**
   ```
   Resource Attribute          → CAF Module(s)
   ────────────────────────────────────────────
   subnet_id                   → vnets, virtual_subnets
   service_plan_id             → service_plans, app_service_plans (legacy)
   target_resource_id          → storage_accounts, virtual_machines, aks_clusters
   workspace_id                → log_analytics
   storage_account_id          → storage_accounts
   key_vault_id                → keyvaults
   managed_identity_ids        → managed_identities
   ```

**3. Update variables.tf remote_objects:**
   ```hcl
   variable "remote_objects" {
     type = object({
       resource_groups      = optional(map(any), {})
       # Add EVERY identified dependency:
       storage_accounts     = optional(map(any), {})
       virtual_machines     = optional(map(any), {})
       aks_clusters         = optional(map(any), {})
       # etc.
     })
     default = {}
   }
   ```

**4. Document in settings variable:**
   ```hcl
   variable "settings" {
     description = <<DESCRIPTION
       - attribute_id - (Optional) Direct Azure resource ID
       - attribute - (Optional) Key-based reference (alternative)
         - key - Resource key in landing zone
         - lz_key - (Optional) Cross-landing-zone key
       DESCRIPTION
   }
   ```

**5. Implement resolution in locals.tf:**
   ```hcl
   # In locals.tf
   lz_key = try(var.settings.resource.lz_key, var.client_config.landingzone_key)
   resource_key = try(var.settings.resource.key, var.settings.resource_key)
   
   resource_id = coalesce(
     try(var.settings.resource_id, null),  # Direct ID
     try(var.remote_objects.resources[local.lz_key][local.resource_key].id, null)  # Key-based
   )
   ```
   - Then reference in resource: `attribute_id = local.resource_id`

### Step 12: Create Example Configuration

Create example at: `examples/<category>/<module_name>/100-simple-<module_name>/configuration.tfvars`

```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  test_rg = {
    name = "<module_name>-test-1"  # NO prefix, azurecaf adds it
  }
}

<category> = {
  <module_name> = {
    instance1 = {
      name = "<module_name>-instance-1"
      resource_group = {
        key = "test_rg"
      }
      # Add minimal required configuration
      
      tags = {
        environment = "dev"
        purpose     = "example"
      }
    }
  }
}
```

### Step 12: Run Mock Tests (MANDATORY)

**Mock tests validate module syntax without Azure deployment using the same configuration files:**

```bash
cd examples
terraform init -upgrade
terraform test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<module_name>/100-simple-<module_name>/configuration.tfvars \
  -verbose
```

**Alternative**: `terraform -chdir=examples test -test-directory=./tests/mock -var-file=...`

**Mock tests MUST pass before proceeding.** They validate:
- ✅ All variable references are correct
- ✅ Resource syntax is valid
- ✅ Dependencies properly resolved
- ✅ No circular dependencies

### Step 12.5: Real Deployment Test (OPTIONAL)

**⚠️ CRITICAL: Only after mock tests pass, optionally test real Azure deployment:**

```bash
# 1. ALWAYS verify Azure subscription FIRST
az account show --query "{subscriptionId:id, name:name, state:state}" -o table

# 2. CONFIRM with user this is the correct subscription
# MUST get explicit confirmation before proceeding

# 3. Export subscription ID
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $ARM_SUBSCRIPTION_ID"

# 4. Plan with same configuration file used for mock test
cd examples
terraform plan -var-file=./<category>/<module_name>/100-simple-<module_name>/configuration.tfvars
```

**Key Point**: Mock tests and deployment use the same configuration files in `examples/<category>/<module_name>/`.

Common errors:
- "Reference to undeclared input variable" → Check variable names match `var.settings`
- "Invalid reference" → Check iterator names (avoid reserved keywords like `module`)
- "Call to function coalesce failed: no non-null, non-empty-string arguments" → Move resolution logic to aggregator (see Step 11.5)

### Step 13: Root Module Integration (8 Steps)

**Step 13.1: Create Root Aggregator File** `/<category>_<module_name>s.tf`

```hcl
module "<module_name>s" {
  source   = "./modules/<category>/<module_name>"
  for_each = local.<category>.<module_name>s

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    resource_groups = local.combined_objects_resource_groups
    # CRITICAL: Add ALL dependencies identified in Step 11
    storage_accounts   = local.combined_objects_storage_accounts
    virtual_machines   = local.combined_objects_virtual_machines
    aks_clusters       = local.combined_objects_aks_clusters
    # Add every remote_object from variables.tf
  }
}

output "<module_name>s" {
  value = module.<module_name>s
}
```

**Step 13.2-13.5:** Follow root-module-integration skill for remaining steps.

## Validation Checklist

Before marking complete:

- [ ] **Pre-requisites: ALL related resources identified and listed**
- [ ] Step 0 completed: ALL resource attributes validated with MCP Terraform
- [ ] Step 11 completed: ALL resource ID dependencies identified and documented
- [ ] Resource not deprecated
- [ ] Directory structure at correct depth (modules/category/module_name/)
- [ ] Standard variables implemented (global_settings, client_config, settings, etc.)
- [ ] remote_objects variable includes ALL identified dependencies
- [ ] Standard locals implemented (module_tag, tags, location, resource_group_name)
- [ ] **ALL resource ID resolution in locals.tf** (not in resource blocks or aggregator)
- [ ] **Pattern selection correct**:
  - [ ] Single type → Pattern 1 (coalesce)
  - [ ] Multi-type conditional → Pattern 2 (ternary cascade)
  - [ ] Explicit checks needed → Pattern 3 (can() + ternary)
- [ ] azurecaf_name.tf created (if resource has name)
- [ ] Main resource uses all validated attributes from Step 0
- [ ] Main resource references locals for all resource IDs (not inline coalesce)
- [ ] Root aggregator passes ALL dependencies in remote_objects block
- [ ] Root aggregator does NOT resolve resource IDs (passes settings directly)
- [ ] Diagnostics integration added (if supported)
- [ ] Private endpoint integration added (if supported)
- [ ] **All related resources in the service implemented (not just one)**
- [ ] Managed identities pattern implemented (if supported)
- [ ] Outputs expose important values
- [ ] Example created following naming convention (100-simple-*)
- [ ] Mock tests pass successfully
- [ ] Root module integration completed (8 steps)

## Common Mistakes to Avoid

❌ **NEVER** skip Step 0 (schema validation)
❌ **NEVER** use resource-specific variable names (e.g., `var.managed_redis`)
❌ **NEVER** hardcode values (location, resource_group_name, tags)
❌ **NEVER** include azurecaf prefixes in example names
❌ **NEVER** commit without passing mock tests
❌ **NEVER** implement deprecated resources
❌ **NEVER** resolve resource IDs in aggregator - always in module locals
  - Symptom: Using `merge()` in aggregator to add resolved IDs to settings
  - Solution: ALL resolution in module `locals.tf`, aggregator just passes `settings = each.value`
❌ **NEVER** use multiple `try()` in `coalesce()` that all might return null
  - Symptom: "coalesce failed: no non-null, non-empty-string arguments"
  - Solution: Use ternary cascade (Pattern 2) for conditional multi-type resolution

## References

- Main instructions: `.github/copilot-instructions.md`
- Module instructions: `.github/instructions/terraform-modules.instructions.md`
- Example instructions: `.github/instructions/terraform-examples.instructions.md`
