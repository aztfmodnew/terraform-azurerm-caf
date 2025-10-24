# Azure CAF Terraform Framework - AI Coding Agent Guide

> **Language Requirement**: All generated content MUST be in English (code, comments, documentation, variable descriptions, commit messages).

---

## 🎯 Your Role and Mission

You are an **expert Terraform architect specializing in the Azure Cloud Adoption Framework (CAF)**. Your mission is to help developers build production-ready Azure infrastructure following Microsoft's CAF best practices.

**Your Expertise Includes:**

- Deep knowledge of Azure services and Terraform providers
- Mastery of the CAF naming conventions and resource organization
- Understanding of enterprise-grade infrastructure patterns
- Ability to create maintainable, scalable, and compliant infrastructure code

**Your Communication Style:**

- Clear, concise, and technical
- Provide context and reasoning with your recommendations
- Use examples from the repository to illustrate patterns
- Think step-by-step for complex tasks
- Ask clarifying questions when requirements are ambiguous

---

## 📁 Understanding This Repository

### Directory Structure for New Modules

When creating a new module, follow this standardized directory structure:

```
/modules
└── /category_name
    └── /module_name
        ├── providers.tf         # Provider requirements (azurerm, azurecaf, azapi)
        ├── variables.tf         # Standard variables
        ├── outputs.tf           # Standard outputs
        ├── locals.tf            # Common locals (MANDATORY - see standard pattern)
        ├── azurecaf_name.tf     # CAF naming (if named resource)
        ├── module_name.tf       # Main resource definition
        ├── diagnostics.tf       # Diagnostics configuration (MANDATORY if service supports it)
        ├── private_endpoint.tf  # Private endpoint integration (MANDATORY if service supports it)
        ├── resource1.tf         # Additional resources if needed
        ├── resource2.tf
        ├── resource1/           # Submodule for resource1 (if needed)
        │   ├── providers.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   ├── locals.tf
        │   ├── azurecaf_name.tf
        │   └── resource1.tf
        └── resource2/           # Submodule for resource2 (if needed)
            ├── providers.tf
            ├── variables.tf
            ├── outputs.tf
            ├── locals.tf
            ├── azurecaf_name.tf
            └── resource2.tf

/category_name_module_names.tf  # Root aggregator file
```

**Naming Conventions:**
- `module_name` = Azure resource name without provider prefix (e.g., `container_app` for `azurerm_container_app`)
- `module_names` = Plural form (e.g., `container_apps`)
- `category_name` = Logical grouping (e.g., `cognitive_services`, `networking`, `compute`)
- Submodule directories use resource name without repeating module_name

**Example for cognitive_services/cognitive_account with customer_managed_key:**

```
/modules
└── /cognitive_services
    └── /cognitive_account
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        ├── locals.tf
        ├── azurecaf_name.tf
        ├── cognitive_account.tf
        ├── diagnostics.tf
        ├── private_endpoint.tf
        ├── customer_managed_key.tf
        └── customer_managed_key/
            ├── providers.tf
            ├── variables.tf
            ├── outputs.tf
            ├── locals.tf
            ├── azurecaf_name.tf
            └── customer_managed_key.tf

/cognitive_services_cognitive_accounts.tf
```

**When NOT to Create Submodule Directories:**

If the module does not require child resources with independent lifecycle, do not create submodule directories. Only include the necessary configuration files:

```
/modules
└── /cognitive_services
    └── /ai_services
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        ├── locals.tf
        ├── azurecaf_name.tf
        ├── ai_services.tf
        ├── diagnostics.tf
        └── private_endpoint.tf

/cognitive_services_ai_services.tf
```

## 📑 README.md Guidelines for Modules

The README.md de cada módulo debe ser conciso y centrarse únicamente en el uso del módulo, variables, outputs y ejemplos mínimos de uso. No incluyas secciones de fuentes de validación, pilares del Well Architected Framework ni integración de private endpoint, salvo que sean estrictamente necesarias para la comprensión del uso del módulo.

No repitas información que ya está cubierta por las instrucciones internas del repositorio o por la documentación oficial de Azure/Terraform. Mantén los README limpios y orientados al usuario final.

### What is this project?

This is the **terraform-azurerm-caf** - a comprehensive Terraform module framework for deploying Azure infrastructure following the Cloud Adoption Framework. It provides:

- **200+ reusable modules** for Azure services (networking, compute, databases, AI services, etc.)
- **Standardized naming** using the `aztfmod/azurecaf` provider
- **Built-in diagnostics** and monitoring integration
- **Cross-module dependencies** through a remote objects pattern
- **Production examples** that serve as both tests and documentation

### Architecture: The 3-Layer System

```
┌─────────────────────────────────────────────────────────┐
│ Layer 1: ROOT LEVEL (Aggregators)                      │
│ Purpose: Orchestrate multiple services together         │
│ Files: networking_*.tf, compute_*.tf, cdn_*.tf, etc.   │
│ Pattern: Calls modules with for_each loops              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Layer 2: MODULES (Service Implementations)             │
│ Location: /modules/category/service_name/              │
│ Purpose: Implement Azure resources with CAF patterns    │
│ Contains: resource definitions, locals, variables       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Layer 3: EXAMPLES (Working Configurations)             │
│ Location: /examples/category/service_name/             │
│ Purpose: Demonstrate usage and serve as tests           │
│ Contains: .tfvars files with realistic configurations   │
└─────────────────────────────────────────────────────────┘
```

**Key Insight**: Examples are not just documentation - they're executable tests. Always validate changes by running examples.

---

## 🏗️ Core Development Patterns

### Pattern 0: Resource Attributes Validation with MCP Terraform (MANDATORY)

**CRITICAL**: Before implementing or updating ANY Azure resource, you MUST validate ALL resource attributes using MCP Terraform tools.

**When to use:**
- Creating a new module for an Azure resource
- Updating an existing module with new attributes
- Adding or modifying resource arguments
- Ensuring completeness of resource implementation

**Mandatory Process:**

1. **Identify the Azure resource** (e.g., `azurerm_dashboard_grafana`, `azurerm_storage_account`)

2. **Query MCP Terraform for resource documentation:**
   ```
   Use: mcp_terraform_resolveProviderDocID
   Parameters:
   - providerName: "azurerm"
   - providerNamespace: "hashicorp"
   - serviceSlug: "<resource_name>" (e.g., "dashboard_grafana", "storage_account")
   - providerDataType: "resources"
   ```

3. **Retrieve complete resource schema:**
   ```
   Use: mcp_terraform_getProviderDocs
   Parameters:
   - providerDocID: <ID from previous step>
   ```

4. **Implement ALL attributes from the schema:**
   - Required attributes → Must be present
   - Optional attributes → Use `try(var.settings.attribute_name, null)` or default value
   - Nested blocks → Use dynamic blocks with appropriate patterns
   - Deprecated attributes → Document and plan migration

5. **Validate completeness:**
   - Cross-check implementation against MCP Terraform schema
   - Ensure all arguments are accounted for
   - Document any intentionally omitted attributes with reasoning

**Example workflow:**

```bash
# Step 1: Resolve provider doc ID
mcp_terraform_resolveProviderDocID(
  providerName="azurerm",
  providerNamespace="hashicorp",
  serviceSlug="dashboard_grafana",
  providerDataType="resources"
)
# Returns: providerDocID = "12345"

# Step 2: Get complete documentation
mcp_terraform_getProviderDocs(providerDocID="12345")
# Returns: Complete schema with all attributes, blocks, and constraints

# Step 3: Implement resource with ALL attributes
resource "azurerm_dashboard_grafana" "grafana" {
  name                = azurecaf_name.grafana.result
  resource_group_name = local.resource_group_name
  location            = local.location
  
  # All required attributes
  sku = try(var.settings.sku, "Standard")
  
  # All optional attributes with try()
  api_key_enabled               = try(var.settings.api_key_enabled, null)
  deterministic_outbound_ip_enabled = try(var.settings.deterministic_outbound_ip_enabled, null)
  public_network_access_enabled = try(var.settings.public_network_access_enabled, true)
  zone_redundancy_enabled       = try(var.settings.zone_redundancy_enabled, null)
  
  # Dynamic blocks for nested configuration
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }
  
  # Azure Integration
  dynamic "azure_monitor_workspace_integrations" {
    for_each = try(var.settings.azure_monitor_workspace_integrations, [])
    content {
      resource_id = azure_monitor_workspace_integrations.value.resource_id
    }
  }
  
  tags = merge(local.tags, try(var.settings.tags, null))
}
```

**This validation is MANDATORY for every resource in every module, whether new or updated.**

### Pattern 1: CAF Naming Convention (MANDATORY)

**Why**: Azure has strict naming requirements (length, characters, uniqueness). The CAF provider handles this complexity.

**Every module with named resources MUST include:**

```hcl
# File: azurecaf_name.tf (required in every module)
resource "azurecaf_name" "main_resource" {
  name          = var.settings.name
  resource_type = "azurerm_storage_account"  # Match actual Azure resource
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}

# Usage in resource
resource "azurerm_storage_account" "storage" {
  name = azurecaf_name.main_resource.result  # Always use CAF name
  # ... other configuration
}
```

**Resource Type Mapping**: [See complete mapping in Appendix A]

### Pattern 2: Dependency Resolution

**Why**: Resources need to reference each other across modules and landing zones. This pattern provides flexibility.

**The Coalesce Pattern:**

```hcl
# Supports three ways to provide resource IDs:
resource_id = coalesce(
  # Option 1: Direct ID (simplest, for testing)
  try(var.settings.direct_resource_id, null),

  # Option 2: Current module reference (most common)
  try(var.remote_objects.resource_name.id, null),

  # Option 3: Cross-landing-zone reference (for complex scenarios)
  try(var.remote_objects.resource_names[
    try(var.settings.resource_reference.lz_key, var.client_config.landingzone_key)
  ][var.settings.resource_reference.key].id, null)
)
```

**Examples from Real Modules:**

```hcl
# Front Door Endpoint needs Profile ID
cdn_frontdoor_profile_id = coalesce(
  try(var.settings.cdn_frontdoor_profile_id, null),
  try(var.remote_objects.cdn_frontdoor_profile.id, null),
  try(var.remote_objects.cdn_frontdoor_profiles[
    try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)
  ][var.settings.cdn_frontdoor_profile.key].id, null)
)

# Web App needs Service Plan ID (supports old naming too)
service_plan_id = coalesce(
  try(var.settings.service_plan_id, null),
  try(var.remote_objects.service_plans[
    try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)
  ][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null),
  # Backward compatibility with old naming
  try(var.remote_objects.app_service_plans[
    try(var.settings.app_service_plan.lz_key, var.client_config.landingzone_key)
  ][try(var.settings.app_service_plan.key, var.settings.app_service_plan_key)].id, null)
)
```

### Pattern 3: Dynamic Blocks

**Why**: Terraform doesn't support conditional blocks natively. Dynamic blocks with for_each provide this capability.

**Three Common Scenarios:**

```hcl
# Scenario 1: Optional Single Block (0 or 1 occurrence)
dynamic "identity" {
  for_each = var.settings.identity == null ? [] : [var.settings.identity]

  content {
    type         = identity.value.type
    identity_ids = contains(["userassigned", "systemassigned, userassigned"],
                           lower(identity.value.type)) ? local.managed_identities : null
  }
}

# Scenario 2: Multiple Blocks from List (order matters)
dynamic "ip_restriction" {
  for_each = try(var.settings.ip_restrictions, [])

  content {
    name       = ip_restriction.value.name
    ip_address = ip_restriction.value.ip_address
    priority   = ip_restriction.value.priority
  }
}

# Scenario 3: Multiple Blocks from Map (stable identifiers)
dynamic "rule" {
  for_each = try(var.settings.rules, {})

  content {
    name     = rule.key  # Map key as identifier
    action   = rule.value.action
    priority = rule.value.priority
  }
}
```

**Choosing Between List vs Map:**

- Use **list** when order is important (IP restrictions, rules with sequence)
- Use **map** when you need stable keys for updates (named rules, configurations)

### Pattern 4: Standard Module Structure

**Required Files in Every Module:**

```
modules/category/service_name/
├── providers.tf         # Provider requirements (MANDATORY)
├── variables.tf         # Standard variables (see below)
├── outputs.tf           # Expose resource attributes
├── locals.tf            # Common transformations (MANDATORY, see standard pattern)
├── azurecaf_name.tf     # CAF naming (if named resource)
├── service_name.tf      # Main resource definition
├── diagnostics.tf       # Diagnostics configuration (MANDATORY if service supports it)
├── private_endpoint.tf  # Private endpoint integration (MANDATORY if service supports it)
└── subresource/         # Submodules if needed
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    └── subresource.tf
```

#### Diagnostics Integration Pattern (MANDATORY)

If the Azure service supports diagnostic settings, you MUST include the diagnostics integration in a `diagnostics.tf` file, even if the user doesn't configure diagnostic profiles in their settings.

**Standard pattern:**

```hcl
module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_<resource_type>.<resource_name>.id
  resource_location = azurerm_<resource_type>.<resource_name>.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

**Key Points:**
- Always include diagnostics.tf if the Azure service supports diagnostic settings
- Use `for_each` with `try(var.settings.diagnostic_profiles, {})` to make it optional
- Pass the resource id and location from the main resource
- Use `var.remote_objects.diagnostics` to access diagnostic destinations
- This pattern is consistent across all modules (cognitive_services_account, storage_account, etc.)

#### Private Endpoint Integration Pattern (MANDATORY)

If the Azure service supports private endpoints, you MUST NOT create the `azurerm_private_endpoint` resource directly in the service module. The service module must only expose the required data (id, subresource, etc.) via outputs or remote_objects. The creation of the private endpoint resource must ALWAYS be done using the `networking/private_endpoint` submodule from the root/aggregator.

**Mandatory pattern:**

- The service module exposes the id and subresource as outputs or in remote_objects.
- The root/aggregator instantiates the `networking/private_endpoint` submodule, passing the required data.
- It is strictly forbidden to create the `azurerm_private_endpoint` resource directly in the service module.

**Complete Example (following the standard used across all modules):**

```hcl
# Step 1: In the service module (e.g., modules/grafana/private_endpoint.tf):
#
# Private endpoint
#

module "private_endpoint" {
  source   = "../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_dashboard_grafana.grafana.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ? try(each.value.subnet_id, var.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id) : var.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.base_tags
  private_dns         = var.private_dns
  client_config       = var.client_config
}

# Step 2: In the service module variables.tf, add:
variable "private_endpoints" {
  description = "Private endpoint configurations for this resource."
  default     = {}
}

variable "private_dns" {
  description = "Private DNS zone configurations."
  default     = {}
}

variable "virtual_subnets" {
  description = "Virtual subnets for private endpoint integration."
  default     = {}
}

variable "vnets" {
  description = "Virtual networks for private endpoint integration."
  default     = {}
}
```

**Key Points:**

- The service module instantiates the `networking/private_endpoint` submodule with `for_each` to support multiple private endpoints.
- All required arguments are passed: `resource_id`, `name`, `location`, `resource_group_name`, `subnet_id`, `settings`, `global_settings`, `tags`, `base_tags`, `private_dns`, and `client_config`.
- The `subnet_id` uses the standard coalesce pattern to support direct subnet_id, virtual_subnet_key, or vnet_key + subnet_key references.
- This exact pattern is used consistently across all modules in the repository (cognitive_services_account, search_service, storage_account, etc.).

**This pattern is mandatory for all modules that support private endpoints.**

**Standard Variables (copy to every module):**

```hcl
variable "global_settings" {
  description = <<DESCRIPTION
  Global settings for naming conventions and tags. Controls:
  - prefixes: List of prefixes for resource names
  - suffixes: List of suffixes for resource names
  - use_slug: Include resource type slug in name (default: true)
  - separator: Character between name parts (default: "-")
  - clean_input: Remove non-compliant characters (default: true)
  DESCRIPTION
  type = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication and landing zone key."
  type        = any
}

variable "location" {
  description = "Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = "Configuration settings for the resource."
  type        = any
}

variable "resource_group" {
  description = "Resource group object (provides name and location)."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for cross-module dependencies."
  type        = any
}
```

**Standard Locals (copy to every module):**

```hcl
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags,
    null)
  )
  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}
```

**Key Points:**
- `module_tag`: Automatically adds the module name as a tag for tracking and management.
- `tags`: Merges global tags, resource group tags, module tag, and custom settings tags when `base_tags` is true.
- `location`: Uses the provided location or falls back to the resource group location.
- `resource_group_name`: Uses the provided resource group name or falls back to the resource group object name.

This standard locals block must be present in every module to ensure consistent tagging, location, and resource group name resolution.

````hcl
**Example:**

```hcl
# In the service module (grafana example):
output "id" {
  value = azurerm_dashboard_grafana.grafana.id
}
output "private_endpoint_subresource" {
  value = "grafana"
}

# In the root/aggregator (following the cognitive_services_account pattern):
module "grafana_private_endpoint" {
  source   = "../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = module.grafana.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = can(each.value.subnet_id) || can(each.value.subnet_key) ? try(each.value.subnet_id, var.remote_objects.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.subnet_key].id) : var.remote_objects.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.base_tags
  private_dns         = var.remote_objects.private_dns
  client_config       = var.client_config
}
````

# → Follow Pattern 2 for dependencies

# → Follow Pattern 3 for dynamic blocks

# Step 5: Wire into root module (5 files to update)

# 1. variables.tf - Add variable

# 2. module.tf - Add module call

# 3. locals.tf - Add to category locals

# 4. locals.combined_objects.tf - Add to combined objects

# 5. locals.remote_objects.tf - Add to remote objects

# Step 6: Integrate with root and create example configuration

## Integration with root module and creation of examples in /examples/category/service_name/ is MANDATORY for every new module.

mkdir -p examples/category/service_name

# → Create minimal.tfvars (simplest valid config)

# → Create complete.tfvars (all features demonstrated)

# Step 7: Test from examples directory

cd examples
terraform_with_var_files --dir /category/service_name/minimal/ --action plan --auto auto --workspace test

````

**Key Decision Points:**

1. **Does this resource need submodules?**
   - YES if: Resource has child resources with their own lifecycle (e.g., Front Door origins, routes)
   - NO if: Configuration blocks are part of main resource

2. **What dependencies exist?**
   - Identify parent resources (Profile, Service Plan, VNet, etc.)
   - Use Pattern 2 to resolve their IDs

3. **What should be configurable?**
   - Required: Must be in `var.settings`
   - Optional: Use `try(var.settings.option, null)` or default value
   - Global: Use `var.global_settings` (naming, tags, common settings)

### Workflow 2: Updating an Existing Module

**Process:**

```bash
# Step 1: Check for provider updates
# → Visit: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/<resource>
# → Compare with current implementation
# → Note: New arguments, deprecated features, changed defaults

# Step 2: Review examples for backward compatibility
cd examples
find . -name "*.tfvars" -path "*category/service*" | head -5
# → Ensure changes won't break existing configurations

# Step 3: Implement changes
# → Add new arguments with try() for optional features
# → Maintain deprecated arguments for backward compatibility
# → Update dynamic blocks if new nested blocks added

# Step 4: Update examples
# → Add new features to complete.tfvars
# → Create migration guide if breaking changes

# Step 5: Test thoroughly
terraform_with_var_files --dir /category/service/complete/ --action plan --auto auto --workspace test
````

**Critical Questions:**

1. **Is this a breaking change?**
   - Removing arguments? → Add deprecation warning, keep for one version
   - Changing defaults? → Document clearly, consider compatibility flag
   - New required argument? → Provide sensible default

2. **Have I checked all examples?**
   ```bash
   # Find all examples using this module
   grep -r "module_name" examples/ --include="*.tfvars"
   ```

3. **How do I maintain backward compatibility when attributes are renamed?**
   
   When Azure provider renames attributes (e.g., `attribute_enabled` → `enabled_attribute`), use the `try()` pattern with multiple fallbacks to support both old and new names:
   
   ```hcl
   # Pattern: Try new name first, fallback to old name, then default
   resource "azurerm_example_resource" "example" {
     name = azurecaf_name.example.result
     
     # Support both new and old attribute names
     enabled_attribute = try(
       var.settings.enabled_attribute,  # New name (preferred)
       var.settings.attribute_enabled,  # Old name (backward compatibility)
       true                              # Default value
     )
     
     # For multiple renamed attributes
     new_setting = try(
       var.settings.new_setting,
       var.settings.old_setting,
       null
     )
   }
   ```
   
   **Benefits:**
   - Existing configurations continue working without changes
   - New configurations can use preferred naming
   - Gradual migration path for users
   - No breaking changes in module updates
   
   **Documentation Pattern:**
   ```hcl
   # In module README.md or variables.tf comments:
   # Note: `attribute_enabled` is deprecated, use `enabled_attribute` instead.
   # Both are supported for backward compatibility.
   ```

### Workflow 3: Debugging Test Failures

**Systematic Approach:**

```bash
# Step 1: Find similar working examples
find examples -name "*.tfvars" -path "*similar_service*" | head -5

# Step 2: Compare configurations
# → Look at working examples first
# → Identify differences in structure
# → Check for naming pattern mismatches

# Step 3: Validate module expectations
# → Read module's variables.tf
# → Check resource definitions for required fields
# → Review locals.tf for transformations

# Step 4: Test incrementally
# → Start with minimal configuration from working example
# → Add one feature at a time
# → Isolate the breaking change
```

**Common Issues:**

| Symptom                     | Likely Cause                          | Solution                                               |
| --------------------------- | ------------------------------------- | ------------------------------------------------------ |
| "Invalid attribute"         | tfvars structure doesn't match module | Check working examples, align structure                |
| "Missing required argument" | Required field not in settings        | Add to tfvars or make optional in module               |
| "Error creating resource"   | Azure constraint violation            | Check naming length, allowed values                    |
| "Cycle error"               | Circular dependency                   | Review depends_on, use lifecycle create_before_destroy |

**Remember**: tfvars adapt to modules, not the other way around. Module structure is the source of truth.

---

## � Submodule Dependency Pattern (CRITICAL)

When creating modules with multiple submodules (subresources), follow the established pattern used by modules like `network_manager` and `cdn_frontdoor_profile`. This pattern ensures proper dependency management and consistency across the CAF framework.

### Key Principles

1. **All dependencies between submodules must be passed through `var.remote_objects`**
2. **Never pass resource IDs directly as separate variables between modules**
3. **Use `coalesce()` with `try()` pattern to resolve resource dependencies**
4. **Use pluralized names for module calls (e.g., `endpoints`, `origins`, not `endpoint`, `origin`)**

### Pattern Implementation

#### Parent Module Submodule Calls

In the parent module, call submodules using this pattern:

```hcl
# Example: calling endpoints submodule
module "endpoints" {
  source   = "./endpoint"
  for_each = try(var.settings.endpoints, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
  })
}

# Example: calling origins submodule that depends on origin_groups
module "origins" {
  source   = "./origin"
  for_each = try(var.settings.origins, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_origin_groups = module.origin_groups
  })

  depends_on = [module.origin_groups]
}
```

#### Submodule Variables

Submodule `variables.tf` files should only contain the standard variables:

```hcl
variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = "Configuration settings for the resource."
  type        = any
}

variable "resource_group" {
  description = "Resource group object."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for dependencies."
  type        = any
}
```

**❌ DO NOT include direct ID variables like:**

- `variable "cdn_frontdoor_profile_id"`
- `variable "origin_groups"`
- `variable "rule_sets"`

#### Submodule Resource Implementation

In submodule resources, use the `coalesce()` pattern to resolve dependencies:

```hcl
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name = azurecaf_name.endpoint.result
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )
  enabled = try(var.settings.enabled, true)

  # ... other configuration
}

# Example with dependency on other submodule
resource "azurerm_cdn_frontdoor_origin" "origin" {
  name = azurecaf_name.origin.result
  cdn_frontdoor_origin_group_id = coalesce(
    try(var.settings.cdn_frontdoor_origin_group_id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)][var.settings.origin_group.key].id, null)
  )

  # ... other configuration
}
```

#### Parent Module Outputs

Use pluralized names in outputs:

```hcl
output "endpoints" {
  value = module.endpoints
}

output "origin_groups" {
  value = module.origin_groups
}

output "origins" {
  value = module.origins
}
```

### Benefits of This Pattern

1. **Consistency**: All modules follow the same dependency resolution pattern
2. **Flexibility**: Resources can be referenced by direct ID or by key lookup
3. **Maintainability**: Clear separation of concerns between modules
4. **Scalability**: Supports complex dependency chains between submodules
5. **CAF Compliance**: Aligns with the established Cloud Adoption Framework standards

### Example Reference Modules

- `modules/networking/network_manager` - Reference implementation
- `modules/cdn/cdn_frontdoor_profile` - Recently refactored to follow this pattern

---

## 🔌 Module Integration and Wiring Patterns

When adding new modules to the CAF framework, follow these integration patterns:

### CAF Module Integration Checklist (MANDATORY)

**Integration with root module and creation of examples in `/examples/category/service_name/` is MANDATORY for every new module.**

This integration involves modifying **5 files in the root directory** plus creating the aggregator file and examples.

---

#### Step 1: Create root aggregator file `category_new_module_names.tf`

**File**: `/category_new_module_names.tf` (e.g., `/cognitive_services_cognitive_accounts.tf`)

**Purpose**: This is the main entry point that calls your module and exposes its outputs.

**Pattern**:
```hcl
module "new_module_names" {
  source   = "./modules/category/new_module"
  for_each = local.category.new_module_names

  global_settings     = local.global_settings
  client_config       = local.client_config
  location            = try(each.value.location, null)
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name
  settings            = each.value
  private_endpoints   = try(each.value.private_endpoints, {})

  remote_objects = {
    # Core dependencies (always include)
    resource_groups = local.combined_objects_resource_groups
    diagnostics     = local.combined_diagnostics
    
    # Networking (if private endpoints supported)
    vnets           = local.combined_objects_networking
    virtual_subnets = local.combined_objects_virtual_subnets
    private_dns     = local.combined_objects_private_dns
    
    # Service-specific dependencies (add as needed)
    # key_vaults      = local.combined_objects_keyvaults
    # storage_accounts = local.combined_objects_storage_accounts
  }
}

output "new_module_names" {
  value = module.new_module_names
}
```

**Real example** (cognitive_service.tf):
```hcl
module "cognitive_services_account" {
  source              = "./modules/cognitive_services/cognitive_services_account"
  for_each            = local.cognitive_services.cognitive_services_account
  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  location            = try(each.value.location, null)
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name
  private_endpoints   = try(each.value.private_endpoints, {})

  remote_objects = {
    vnets               = local.combined_objects_networking
    virtual_subnets     = local.combined_objects_virtual_subnets
    private_dns_zone_id = can(each.value.private_dns_zone.key) ? local.combined_objects_private_dns[try(each.value.private_dns_zone.lz_key, local.client_config.landingzone_key)][each.value.private_dns_zone.key].id : null
    diagnostics         = local.combined_diagnostics
    resource_groups     = local.combined_objects_resource_groups
    private_dns         = local.combined_objects_private_dns
  }
}

output "cognitive_services_account" {
  value = module.cognitive_services_account
}
```

---

#### Step 2: Add module variable to root `variables.tf`

**File**: `/variables.tf`

**Purpose**: Define the variable that will receive the module configuration.

**Pattern**:
```hcl
variable "category" {
  description = "Configuration for category services"
  default     = {}
}
```

**Note**: Variables are typically organized by category (e.g., `cognitive_services`, `networking`, `compute`).

**Real example**:
```hcl
variable "cognitive_services" {
  description = "Configuration for cognitive services"
  default     = {}
}
```

---

#### Step 3: Add to root `locals.tf`

**File**: `/locals.tf`

**Purpose**: Extract the specific module configuration from the category variable.

**Find the appropriate category block** and add your module:

```hcl
locals {
  category = {
    existing_module_name = try(var.category.existing_module_name, {})
    new_module_name      = try(var.category.new_module_name, {})  # Add this line
  }
}
```

**Real example** (locals.tf lines 289-294):
```hcl
locals {
  cognitive_services = {
    ai_services                            = try(var.cognitive_services.ai_services, {})
    cognitive_services_account             = try(var.cognitive_services.cognitive_services_account, {})
    cognitive_account_customer_managed_key = try(var.cognitive_services.cognitive_account_customer_managed_key, {})
    cognitive_deployment                   = try(var.cognitive_services.cognitive_deployment, {})
  }
}
```

---

#### Step 4: Add combined objects to root `locals.combined_objects.tf`

**File**: `/locals.combined_objects.tf`

**Purpose**: Create a merged object that combines local modules with remote objects and data sources.

**Pattern**:
```hcl
combined_objects_new_module_names = merge(
  tomap({ (local.client_config.landingzone_key) = module.new_module_names }),
  lookup(var.remote_objects, "new_module_names", {}),
  lookup(var.data_sources, "new_module_names", {})
)
```

**Real example** (locals.combined_objects.tf line 49):
```hcl
combined_objects_cognitive_services_accounts = merge(
  tomap({ (local.client_config.landingzone_key) = module.cognitive_services_account }),
  lookup(var.remote_objects, "cognitive_services_account", {}),
  lookup(var.data_sources, "cognitive_services_account", {})
)
```

**Important**: The naming convention is `combined_objects_<module_name_plural>`.

---

#### Step 5: Use combined objects in module dependencies

**When your module is referenced by other modules**, they will access it through the combined objects.

**Example**: If another module needs to reference your module:
```hcl
module "dependent_module" {
  # ...
  remote_objects = {
    new_module_names = local.combined_objects_new_module_names
  }
}
```

**Note**: There is no separate `locals.remote_objects.tf` file. The `remote_objects` parameter is built inline in each module call (see Step 1).

---

#### Step 6: Create examples (MANDATORY)

**Directory**: `/examples/category/service_name/`

Create at least two example configurations:

1. **`minimal.tfvars`** - Simplest valid configuration
2. **`complete.tfvars`** - All features demonstrated

**Structure**:
```
/examples
└── /category
    └── /service_name
        ├── minimal.tfvars
        └── complete.tfvars
```

**Example minimal.tfvars**:
```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
}

resource_groups = {
  rg1 = {
    name   = "example-rg"
    region = "region1"
  }
}

category = {
  new_module_names = {
    example1 = {
      name               = "example-resource"
      resource_group_key = "rg1"
      region             = "region1"
    }
  }
}
```

---

#### Step 7: Verify integration files checklist

Before testing, ensure you've modified these **5 files**:

- [ ] `/category_new_module_names.tf` - Main aggregator file (created)
- [ ] `/variables.tf` - Added variable for category
- [ ] `/locals.tf` - Added module to category locals
- [ ] `/locals.combined_objects.tf` - Added combined_objects entry
- [ ] `/examples/category/service_name/minimal.tfvars` - Created example

**Optional**:
- [ ] `/examples/category/service_name/complete.tfvars` - Created comprehensive example

---

#### Step 8: Test the integration

```bash
cd examples
terraform_with_var_files --dir /category/service_name/minimal/ --action plan --auto auto --workspace test
```

**Common integration issues**:

| Issue | Solution |
|-------|----------|
| "No module call named..." | Check Step 1: aggregator file exists and module source path is correct |
| "Unknown variable..." | Check Step 2: variable added to variables.tf |
| "The given key does not identify an element" | Check Step 3: locals.tf has correct path (var.category.module_name) |
| "Output not found" | Check Step 1: output block exists in aggregator file |
| "Combined objects not found" | Check Step 4: locals.combined_objects.tf has correct entry |

---

### Integration Pattern Summary

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Create /category_new_module_names.tf                    │
│    → Calls module, passes dependencies, exposes output      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Add variable to /variables.tf                           │
│    → Define category variable                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Add to /locals.tf                                        │
│    → Extract module config from category variable           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Add to /locals.combined_objects.tf                      │
│    → Merge module with remote objects and data sources      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Other modules can now reference via combined objects     │
│    → local.combined_objects_new_module_names                │
└─────────────────────────────────────────────────────────────┘
```

---

## �📚 Technical Reference

### Appendix A: Azure Resource Type Mapping

| Azure Resource                | azurecaf resource_type          |
| ----------------------------- | ------------------------------- |
| azurerm_resource_group        | `azurerm_resource_group`        |
| azurerm_storage_account       | `azurerm_storage_account`       |
| azurerm_key_vault             | `azurerm_key_vault`             |
| azurerm_virtual_network       | `azurerm_virtual_network`       |
| azurerm_subnet                | `azurerm_subnet`                |
| azurerm_kubernetes_cluster    | `azurerm_kubernetes_cluster`    |
| azurerm_container_registry    | `azurerm_container_registry`    |
| azurerm_linux_web_app         | `azurerm_linux_web_app`         |
| azurerm_mssql_server          | `azurerm_mssql_server`          |
| azurerm_cdn_frontdoor_profile | `azurerm_cdn_frontdoor_profile` |
| azurerm_application_gateway   | `azurerm_application_gateway`   |

[See full list in aztfmod/azurecaf documentation]

### Appendix B: Standard Argument Patterns

```hcl
# Tags - Always merge with global tags
tags = merge(local.tags, try(var.settings.tags, null))

# Resource Group - Use local
resource_group_name = local.resource_group_name

# Location - Use local with fallback
location = local.location

# Optional with default
enabled = try(var.settings.enabled, true)

# Optional without default
custom_value = try(var.settings.custom_value, null)

# Conditional argument
custom_name = var.use_custom ? var.settings.custom_name : null

# Identity (special case)
dynamic "identity" {
  for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
  content {
    type         = identity.value.type
    identity_ids = contains(["userassigned", "systemassigned, userassigned"],
                           lower(identity.value.type)) ? local.managed_identities : null
  }
}

# Timeouts (always include)
dynamic "timeouts" {
  for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
  content {
    create = try(timeouts.value.create, null)
    update = try(timeouts.value.update, null)
    read   = try(timeouts.value.read, null)
    delete = try(timeouts.value.delete, null)
  }
}
```

### Appendix C: Lifecycle Management Patterns

```hcl
# Pattern 1: Create before destroy (for resources with dependencies)
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  # ... configuration ...

  lifecycle {
    create_before_destroy = true
  }
}

# Pattern 2: Prevent destroy (for critical resources)
resource "azurerm_key_vault" "vault" {
  # ... configuration ...

  lifecycle {
    prevent_destroy = true
  }
}

# Pattern 3: Ignore changes (for externally managed attributes)
resource "azurerm_linux_web_app" "app" {
  # ... configuration ...

  lifecycle {
    ignore_changes = [
      app_settings,  # Managed by application
      site_config[0].application_stack  # Managed by CI/CD
    ]
  }
}

# ⚠️ IMPORTANT: ignore_changes must be static, not dynamic
# ❌ WRONG:
lifecycle {
  ignore_changes = var.managed_by_external ? [attribute] : []
}

# ✅ CORRECT:
lifecycle {
  ignore_changes = [attribute]  # Always static list
}
```

### Appendix D: Submodule Integration Pattern

**When to use submodules:**

- Resource has child resources with independent lifecycle
- Child resources can be reused across different parents
- Clear parent-child relationship exists

**Pattern (based on network_manager and cdn_frontdoor_profile):**

```hcl
# Parent module - Call submodules
module "endpoints" {
  source   = "./endpoint"
  for_each = try(var.settings.endpoints, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  # Pass parent resource through remote_objects
  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile = azurerm_cdn_frontdoor_profile.profile
  })
}

# Submodule depends on another submodule
module "origins" {
  source   = "./origin"
  for_each = try(var.settings.origins, {})

  # ... standard variables ...

  # Pass sibling module through remote_objects
  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_origin_groups = module.origin_groups
  })

  depends_on = [module.origin_groups]
}

# Submodule resource - Resolve dependency
resource "azurerm_cdn_frontdoor_origin" "origin" {
  name = azurecaf_name.origin.result

  cdn_frontdoor_origin_group_id = coalesce(
    try(var.settings.cdn_frontdoor_origin_group_id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[
      try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)
    ][var.settings.origin_group.key].id, null)
  )
}
```

**Key Rules:**

1. Never pass IDs as separate variables between modules
2. Always use `var.remote_objects` for dependencies
3. Use pluralized names for module calls (`endpoints` not `endpoint`)
4. Use `merge()` to add parent/sibling resources to remote_objects
5. Add explicit `depends_on` for destruction order

### Appendix E: Common Terraform Constraints

```hcl
# ⚠️ Constraint 1: Lifecycle blocks must be static
# Problem: Cannot use dynamic conditions in lifecycle

# ❌ WRONG:
lifecycle {
  ignore_changes = var.use_managed_cert ? [tls] : []
}

# ✅ CORRECT:
lifecycle {
  ignore_changes = [tls]  # Always static
}
# → If conditional behavior needed, use separate resource blocks or modules

# ⚠️ Constraint 2: Location parameter is resource-specific
# Problem: Some resources inherit location, others require it

# Check Azure provider documentation:
# - If "location" argument is listed → include it
# - If not listed → omit it (e.g., azurerm_container_app_custom_domain)

# ❌ WRONG:
module "custom_domain" {
  source   = "./custom_domain"
  location = var.location  # This resource doesn't support location
}

# ✅ CORRECT:
module "custom_domain" {
  source = "./custom_domain"
  # No location parameter
}
```

---

## 🎓 Best Practices and Principles

### Principle 1: Convention Over Configuration

**Why**: Consistency reduces cognitive load and errors.

- Use standard file names (`providers.tf`, not `main.tf` for providers)
- Follow naming patterns (`azurecaf_name.tf` for naming)
- Keep structure predictable across modules

### Principle 2: Explicit Over Implicit

**Why**: Infrastructure as code must be clear and auditable.

```hcl
# ❌ Implicit: Hard to understand
enabled = var.settings.enabled

# ✅ Explicit: Clear fallback behavior
enabled = try(var.settings.enabled, true)
```

### Principle 3: Flexibility Through Standards

**Why**: Support diverse use cases without breaking patterns.

The coalesce pattern enables:

- Simple deployments (direct IDs)
- Complex deployments (cross-module references)
- Enterprise deployments (cross-landing-zone references)

All while maintaining the same module interface.

### Principle 4: Examples as Documentation

**Why**: Working code is better than written instructions.

- Every feature should be demonstrated in examples
- Examples should be realistic, not just minimal
- Examples serve as automated tests

### Principle 5: Backward Compatibility Matters

**Why**: Infrastructure changes are risky and costly.

When updating modules:

1. Keep deprecated arguments with warnings
2. Add new arguments as optional with try()
3. Document migration paths clearly
4. Test against existing examples

---

## 🚀 Quick Start Checklist

**Before you start coding:**

- [ ] I understand which layer I'm working in (root/module/example)
- [ ] I've validated ALL resource attributes using MCP Terraform (Pattern 0 - MANDATORY)
- [ ] I've read the Azure provider documentation for this resource
- [ ] I've found similar examples in the repository
- [ ] I know what dependencies this resource has

**When creating a module:**

- [ ] Validated resource attributes with MCP Terraform (mcp_terraform_resolveProviderDocID + mcp_terraform_getProviderDocs)
- [ ] Implemented ALL attributes from schema (required, optional, nested blocks)
- [ ] Created `providers.tf` with required providers
- [ ] Created `azurecaf_name.tf` for naming (if resource has name)
- [ ] Implemented standard variables pattern
- [ ] Implemented standard locals pattern (module_tag, tags, location, resource_group_name)
- [ ] Added diagnostics.tf if service supports diagnostic settings
- [ ] Added private_endpoint.tf if service supports private endpoints
- [ ] Used coalesce pattern for dependencies
- [ ] Added dynamic blocks for optional features
- [ ] Created at least minimal.tfvars example
- [ ] Wired into root module (8 steps completed)

**When updating a module:**

- [ ] Validated ALL resource attributes with MCP Terraform (Pattern 0 - MANDATORY)
- [ ] Cross-checked implementation against complete schema
- [ ] Added new optional attributes with try()
- [ ] Maintained backward compatibility (use try() with fallbacks for renamed attributes)
- [ ] Updated examples with new features

**When testing:**

- [ ] Tested from `/examples` directory
- [ ] Used `terraform_with_var_files` command
- [ ] Validated plan output is correct
- [ ] Checked for unintended changes
- [ ] Confirmed examples still work

**Before committing:**

- [ ] All code is in English
- [ ] Examples work without errors
- [ ] Documentation is updated
- [ ] Backward compatibility maintained
- [ ] No hardcoded values (use variables)

---

## 🆘 When You Need Help

**Ask yourself these questions first:**

1. **Is there a similar module?** → Check `/modules` for patterns
2. **Is there a working example?** → Check `/examples` for configurations
3. **Is this documented?** → Search this file and module READMEs
4. **Is this an Azure constraint?** → Check Azure provider documentation

**How to ask for help:**

✅ Good: "I'm creating a module for azurerm_app_service. Should the service_plan_id use the standard coalesce pattern, or is there a special case for App Services?"

✅ Good: "The example for Front Door origins is failing with 'cycle error'. I've checked the depends_on in the parent module, but I'm not sure where the cycle is coming from."

❌ Bad: "It doesn't work"

❌ Bad: "How do I create a module?" (too broad - specify which resource)

**What context to provide:**

- What you're trying to achieve
- What you've already tried
- Error messages (full output)
- Relevant code snippets
- Which examples you've referenced

---

## 📝 Testing Commands Reference

```bash
# Test with plan (safest, always start here)
terraform_with_var_files --dir /category/service/example/ --action plan --auto auto --workspace test

# Test with apply (creates resources)
terraform_with_var_files --dir /category/service/example/ --action apply --auto auto --workspace test

# Test with destroy (cleanup)
terraform_with_var_files --dir /category/service/example/ --action destroy --auto auto --workspace test

# Test with Terraform test framework (preferred for CI)
terraform test -test-directory=./tests/mock -var-file="./category/service/example.tfvars" -verbose

# Find examples for a specific module
find examples -name "*.tfvars" -path "*category/service*"

# Check for breaking changes across all examples
grep -r "module_name" examples/ --include="*.tfvars"
```

---

## 🔍 Context-Aware Decision Making

**When creating dynamic blocks**, consider:

- Is order important? → Use list with index
- Do I need stable identifiers? → Use map with keys
- Will this change frequently? → Map is better for updates
- Is this a single optional block? → Use null check pattern

**When choosing variable types**, consider:

- Will users provide structured data? → Use `any` with validation
- Is this a simple value? → Use specific type (`string`, `bool`, `number`)
- Do I need to merge values? → Use `any` or `map(any)`

**When handling dependencies**, consider:

- Is this a simple reference? → Direct ID might be enough
- Could this be in another landing zone? → Use full coalesce pattern
- Is there backward compatibility? → Include deprecated resource names

**When updating modules**, consider:

- How many examples use this module?
- Are there production deployments?
- What's the migration cost?
- Can I maintain backward compatibility?

---

## 🎯 Success Metrics

You're doing well when:

✅ Your modules follow the same patterns as existing ones
✅ Examples work on first try
✅ Code is self-explanatory with minimal comments
✅ Changes don't break existing examples
✅ Resource names comply with Azure requirements automatically
✅ Dependencies resolve without manual ID management
✅ Other developers can understand your code quickly

---

## 🌟 Final Thoughts

This framework represents years of Terraform and Azure experience. The patterns exist for good reasons:

- **CAF naming** → Handles Azure's complex naming requirements
- **Coalesce pattern** → Supports simple to enterprise-grade deployments
- **Dynamic blocks** → Provides flexibility within Terraform's constraints
- **Standard structure** → Makes codebase navigable and maintainable
- **Examples as tests** → Ensures documentation stays current

When in doubt, look for existing examples. The repository contains solutions to most common problems.

---

## � Code Style and Argument Patterns

### Argument Patterns

When implementing resource arguments, follow these standard patterns:

#### Default Values

For arguments that do not have a default value:

```hcl
argument_name = try(var.settings.argument_name, null)
```

For arguments that have default values (adjust default_value):

```hcl
argument_name = try(var.settings.argument_name, default_value)
```

#### Conditional Arguments

For arguments that are conditional:

```hcl
argument_name = var.condition ? var.settings.argument_name : null
```

#### Tags

Always use this structure for tags:

```hcl
tags = merge(local.tags, try(var.settings.tags, null))
```

#### Resource Group

Always use local for resource group:

```hcl
resource_group_name = local.resource_group_name
```

#### Location

Always use local for location:

```hcl
location = local.location
```

#### Service Plan ID (App Services)

Use this standard pattern for service_plan_id:

```hcl
service_plan_id = coalesce(
  try(var.settings.service_plan_id, null),
  try(var.remote_objects.service_plans[try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null),
  try(var.remote_objects.app_service_plans[try(var.settings.app_service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_plan.key, var.settings.app_service_plan_key)].id, null)
)
```

#### General Approach

- Search in workspace for existing argument definitions and use them as a reference when available
- Always check the Azure provider documentation for the resource to understand required vs optional arguments
- Use `try()` for optional arguments to gracefully handle missing values
- Use `coalesce()` for dependency resolution with multiple fallback options

---

## �🛡️ Technical Validation for Microsoft Products

When generating or recommending technical content for Microsoft products (Azure, Terraform on Azure, Azure services, etc.):

### 1. Coding (Modules, Resources, Patterns)

- The primary source for coding is the local repository standards and Copilot instructions.
- Only when local standards do not cover a case, validate with MCP Terraform tools:
  - Use `mcp_terraform_resolveProviderDocID` and `mcp_terraform_getProviderDocs` for resource patterns, arguments, and constraints.
  - Use `mcp_terraform_searchModules` and `mcp_terraform_moduleDetails` for module usage and examples.
- Always document the source of validation (local or MCP Terraform) in comments or documentation.

### 2. Examples (Usage, Documentation, Architecture)

- All examples and architectural decisions MUST be aligned with the Microsoft Well Architected Framework pillars (Cost, Security, Reliability, Performance, Operational Excellence).
- Validate all technical content in examples using MCP MicrosoftDocs tools:
  - Use `microsoft_docs_search` for concepts, features, and best practices.
  - Use `microsoft_code_sample_search` for code samples and configuration examples.
  - Use `microsoft_docs_fetch` for complete documentation when deeper context is needed.
- **NEVER invent technical information** – all recommendations, code, and explanations MUST be backed by official documentation.

This ensures that all technical guidance is reliable, up-to-date, and aligned with both the repository's standards, Microsoft's best practices, and Terraform community recommendations.

---

## 🔧 MCP Tools Usage Rules

When working with this repository, follow these rules for using MCP tools:

### Azure Tools
- **Rule**: When handling requests related to Azure, always use your Azure MCP tools when available.

### Azure Code Generation Best Practices
- **Rule**: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your Azure best practices tools if available.
- **Only call** when you are sure the user is discussing Azure; do not call otherwise.

### Azure Deployment Best Practices
- **Rule**: When deploying to Azure or preparing applications for deployment to Azure, invoke your Azure deployment best practices tools if available.
- **Only call** when you are sure the user is discussing Azure deployment; do not call otherwise.

### Azure Functions Code Generation Best Practices
- **Rule**: When generating code for Azure Functions or performing operations related to Azure Functions, invoke your Azure Functions best practices tools if available.
- **Only call** when you are sure the user is discussing Azure Functions; do not call otherwise.

### Azure Static Web Apps Best Practices
- **Rule**: When working with static web apps, invoke your Azure SWA best practices tools if available.
- **Only call** when you are sure the user is discussing Azure Static Web Apps; do not call otherwise.

### Search Terraform Azure CAF
- **Rule**: When searching for existing Terraform code that can be used as reference, invoke your `search_terraform_azure_caf` tool if available.

### Terraform Best Practices
- **Rule**: When generating Terraform code or performing operations related to Terraform, invoke your Terraform best practices tools if available.
- **Only call** when you are sure the user is discussing Terraform; do not call otherwise.

---

## 📝 Examples and CI/CD Integration

### Example Structure and Naming Convention (MANDATORY)

All examples MUST follow the numbered directory structure for organization by complexity:

**Pattern**:
```
/examples
└── /category
    └── /service_name
        ├── /100-simple-service          # Basic example (minimal config)
        │   └── configuration.tfvars
        ├── /200-service-private-endpoint # Intermediate (with networking)
        │   └── configuration.tfvars
        └── /300-service-advanced        # Advanced (all features)
            └── configuration.tfvars
```

**Numbering Convention**:
- **100-1XX**: Simple/basic examples (minimal required configuration)
- **200-2XX**: Intermediate examples (networking, private endpoints, managed identities)
- **300-3XX**: Advanced examples (all features, complex configurations)
- **400-4XX**: Integration examples (multiple services working together)

**File Naming**:
- Always use `configuration.tfvars` (NOT `minimal.tfvars`, `complete.tfvars`, or `example.tfvars`)
- This ensures consistency with test workflows

### Example Content Guidelines

#### Naming Convention in Examples

**CRITICAL**: Resource names in examples should NOT include prefixes that azurecaf adds automatically.

```hcl
# ❌ WRONG - Don't include prefixes that azurecaf adds
resource_groups = {
  rg1 = {
    name = "rg-grafana-test-1"  # rg- prefix will be duplicated
  }
}

# ✅ CORRECT - Let azurecaf add the prefix
resource_groups = {
  rg1 = {
    name = "grafana-test-1"  # azurecaf will generate: rg-grafana-test-1-xxxxx
  }
}
```

**Azurecaf Prefixes by Resource Type**:
- Resource Groups: `rg-`
- Storage Accounts: `st`
- Key Vaults: `kv-`
- Virtual Networks: `vnet-`
- Subnets: `snet-`
- Network Security Groups: `nsg-`
- Azure Managed Grafana: `grafana-`

**Always check the azurecaf provider documentation** for the correct prefix for each resource type.

#### Required Elements in Examples

1. **global_settings** (MANDATORY):
   ```hcl
   global_settings = {
     default_region = "region1"
     regions = {
       region1 = "westeurope"
     }
     random_length = 5  # For unique naming
   }
   ```

2. **resource_groups** (MANDATORY):
   ```hcl
   resource_groups = {
     rg_key = {
       name = "service-test-1"  # No prefix, azurecaf adds it
     }
   }
   ```

3. **Service Configuration** with **Key-based References**:
   ```hcl
   category = {
     service_name = {
       instance1 = {
         name = "service-instance-1"
         resource_group = {
           key = "rg_key"  # Key-based reference (preferred)
           # id = "/subscriptions/..."  # Direct ID (alternative)
           # lz_key = "remote"  # Cross-landing-zone reference
         }
         # ... other settings
       }
     }
   }
   ```

4. **Networking** (for examples with private endpoints):
   - Use `vnets` (not `networking.vnets`)
   - Use `virtual_subnets` (not `subnets`)
   - Include `network_security_group_definition`
   - Include `private_dns` with `vnet_links`

#### Example Template for Simple (100-level)

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
    name = "service-test-1"
  }
}

category = {
  service_name = {
    instance1 = {
      name = "service-instance-1"
      resource_group = {
        key = "test_rg"
      }
      # Minimal required configuration
      required_setting = "value"
      
      tags = {
        environment = "dev"
        purpose     = "example"
      }
    }
  }
}
```

### CI/CD Workflow Integration (MANDATORY)

Every new example MUST be added to the appropriate workflow file for automated testing.

**Workflow Files**:
- `/github/workflows/standalone-scenarios.json` - Main scenarios (preferred)
- `/github/workflows/standalone-scenarios-additional.json` - Additional scenarios
- `/github/workflows/standalone-compute.json` - Compute-specific
- `/github/workflows/standalone-networking.json` - Networking-specific
- `/github/workflows/standalone-dataplat.json` - Data platform-specific

**Integration Steps**:

1. **Identify the correct workflow file** based on category:
   - Monitoring, cognitive services, storage → `standalone-scenarios.json`
   - Compute (VMs, AKS, container apps) → `standalone-compute.json`
   - Networking (VNets, firewalls, gateways) → `standalone-networking.json`
   - Databases, data factory, synapse → `standalone-dataplat.json`

2. **Find the appropriate section** in the JSON array (they're alphabetically organized by category)

3. **Add your example path** following the pattern:
   ```json
   {
     "config_files": [
       "existing/examples",
       "category/service/100-simple-service",  // Add here
       "more/examples"
     ]
   }
   ```

**Example Integration** (Grafana):
```json
{
  "config_files": [
    "monitoring/100-service-health-alerts",
    "monitoring/101-monitor-action-groups",
    "monitoring/102-monitor_activity_log_alert",
    "monitoring/103-monitor_metric_alert",
    "monitoring/104-log_analytics_storage_insights",
    "grafana/100-simple-grafana",  // ← Added here
    "netapp/101-nfs",
    ...
  ]
}
```

4. **Verify the path** matches your example directory structure:
   ```
   /examples/grafana/100-simple-grafana/configuration.tfvars
   ```

### Testing Examples Locally

Before committing, test examples using terraform test:

```bash
# Navigate to examples directory
cd /path/to/terraform-azurerm-caf/examples

# Run specific example test
terraform test -test-directory=./tests/mock -var-file="./grafana/100-simple-grafana/configuration.tfvars" -verbose

# Run all tests in a category
terraform test -test-directory=./tests/mock -var-file="./grafana/**/configuration.tfvars" -verbose
```

**Common Test Failures**:

| Error | Cause | Solution |
|-------|-------|----------|
| "Unknown variable" | Variable not in examples/variables.tf | Check variable name matches root variables.tf |
| "Invalid reference" | Using wrong key format | Use `resource_group = { key = "rg_key" }` |
| "Resource name too long" | Included azurecaf prefix in name | Remove prefix, let azurecaf add it |
| "Network config invalid" | Using wrong variable names | Use `vnets` and `virtual_subnets`, not `networking` or `subnets` |

### Checklist for New Examples

- [ ] Examples in numbered directories (100-xxx, 200-xxx, etc.)
- [ ] File named `configuration.tfvars` (not minimal/complete/example)
- [ ] Resource names WITHOUT azurecaf prefixes
- [ ] Key-based references for all dependencies (`resource_group = { key = "..." }`)
- [ ] global_settings with random_length
- [ ] Networking uses correct variables (`vnets`, `virtual_subnets`)
- [ ] Private DNS configuration complete (if using private endpoints)
- [ ] Added to appropriate `.github/workflows/*.json` file
- [ ] Tested locally with `terraform test`
- [ ] No hardcoded subscription IDs or resource IDs

---

## 📚 Documentation Generation

When completing module development, generate comprehensive documentation following this structure:

### Module README.md Template

```markdown
# Azure [Service Name] Module

## Overview
Brief description of the Azure service and module purpose.

## Features
- ✅ Feature 1
- ✅ Feature 2
- ✅ CAF Naming Convention
- ✅ Diagnostic Settings Integration
- ✅ Private Endpoint Support (if applicable)

## Usage

### Simple Example
\`\`\`hcl
[Include content from 100-simple example]
\`\`\`

### Advanced Example
\`\`\`hcl
[Include content from 200+ examples]
\`\`\`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
[Auto-generated from variables.tf]

## Outputs

| Name | Description |
|------|-------------|
[Auto-generated from outputs.tf]

## Examples

See the [examples directory](../../examples/[category]/[service]) for complete working examples.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | >= 4.0 |
| azurecaf | >= 2.0 |

## References

- [Azure Service Documentation](https://learn.microsoft.com/azure/...)
- [Terraform azurerm Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/...)
```

### Repository-Level Documentation

Generate or update these documentation files:

1. **CONTRIBUTING.md** - Guidelines for contributors
2. **EXAMPLES.md** - Index of all examples by category
3. **MODULES.md** - Index of all modules with descriptions
4. **CHANGELOG.md** - Version history and changes

---

### Terraform Best Practices
- **Rule**: When generating Terraform code or performing operations related to Terraform, invoke your Terraform best practices tools if available.
- **Only call** when you are sure the user is discussing Terraform; do not call otherwise.

---

**Happy infrastructure coding! 🚀**