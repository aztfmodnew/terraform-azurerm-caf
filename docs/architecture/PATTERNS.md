# Design Patterns

> **Deep dive into terraform-azurerm-caf implementation patterns**

This document explores the core design patterns used throughout the terraform-azurerm-caf framework, explaining the reasoning behind each pattern and providing practical examples.

---

## Table of Contents

1. [Coalesce Pattern](#coalesce-pattern)
2. [Remote Objects Pattern](#remote-objects-pattern)
3. [Dynamic Block Patterns](#dynamic-block-patterns)
4. [CAF Naming Pattern](#caf-naming-pattern)
5. [Diagnostics Integration Pattern](#diagnostics-integration-pattern)
6. [Private Endpoint Pattern](#private-endpoint-pattern)
7. [Tag Inheritance Pattern](#tag-inheritance-pattern)
8. [Resource Group Resolution Pattern](#resource-group-resolution-pattern)
9. [Backward Compatibility Pattern](#backward-compatibility-pattern)
10. [Testing Pattern](#testing-pattern)

---

## Coalesce Pattern

### Purpose

Enable flexible resource references that work in simple, complex, and enterprise scenarios without code changes.

### Problem

Different deployment scenarios require different ways to reference resources:

- **Simple**: Direct IDs for testing
- **Complex**: Key-based references within a landing zone
- **Enterprise**: Cross-landing-zone references

### Solution

Use `coalesce()` with multiple fallback options:

```hcl
resource_id = coalesce(
  # Option 1: Direct ID (simple/testing)
  try(var.settings.resource_id, null),

  # Option 2: Current landing zone reference (common)
  try(var.remote_objects.resources[var.client_config.landingzone_key][var.settings.resource_key].id, null),

  # Option 3: Cross-landing-zone reference (enterprise)
  try(var.remote_objects.resources[var.settings.lz_key][var.settings.resource_key].id, null)
)
```

### Real-World Example: Subnet Resolution

```hcl
# In modules/monitoring/grafana/private_endpoints.tf
subnet_id = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ?
  try(
    # Option 1: Direct subnet ID
    each.value.subnet_id,
    # Option 2: Virtual subnet reference
    var.remote_objects.virtual_subnets[
      try(each.value.lz_key, var.client_config.landingzone_key)
    ][each.value.virtual_subnet_key].id
  ) :
  # Option 3: VNet + subnet key reference
  var.remote_objects.vnets[
    try(each.value.lz_key, var.client_config.landingzone_key)
  ][each.value.vnet_key].subnets[each.value.subnet_key].id
```

**Usage Examples:**

```hcl
# Simple: Direct ID
private_endpoints = {
  pe1 = {
    name      = "grafana-pe"
    subnet_id = "/subscriptions/.../subnets/subnet1"
  }
}

# Complex: Virtual subnet key
private_endpoints = {
  pe1 = {
    name               = "grafana-pe"
    virtual_subnet_key = "private_endpoints_subnet"
  }
}

# Enterprise: Cross-landing-zone
private_endpoints = {
  pe1 = {
    name       = "grafana-pe"
    lz_key     = "shared_services"
    vnet_key   = "hub_vnet"
    subnet_key = "private_endpoints"
  }
}
```

### Benefits

- ✅ Single code path for all scenarios
- ✅ No runtime conditionals needed
- ✅ Graceful fallback behavior
- ✅ Clear precedence order

---

## Remote Objects Pattern

### Purpose

Pass dependencies between modules without tight coupling or circular references.

### Problem

Modules need to reference other modules' outputs, but direct references create:

- Circular dependencies
- Tight coupling
- Inability to reference remote landing zones

### Solution

Aggregate all module outputs into a `remote_objects` map passed to consuming modules:

```hcl
# In root aggregator (grafana.tf)
module "grafana" {
  source = "./modules/monitoring/grafana"

  remote_objects = {
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
    private_dns        = local.combined_objects_private_dns
    diagnostics        = local.combined_diagnostics
    resource_groups    = local.combined_objects_resource_groups
    managed_identities = local.combined_objects_managed_identities
  }
}
```

### Combined Objects Pattern

Root-level `locals.combined_objects.tf` merges three sources:

```hcl
combined_objects_grafana = merge(
  # 1. Local modules (current landing zone)
  tomap({ (local.client_config.landingzone_key) = module.grafana }),

  # 2. Remote objects (other landing zones via tfstate)
  lookup(var.remote_objects, "grafana", {}),

  # 3. Data sources (existing resources)
  lookup(var.data_sources, "grafana", {})
)
```

### Benefits

- ✅ No circular dependencies
- ✅ Supports cross-landing-zone references
- ✅ Modules remain decoupled
- ✅ Consistent access pattern

### Anti-Pattern

```hcl
# ❌ NEVER do this in modules
resource "azurerm_private_endpoint" "pe" {
  subnet_id = module.vnet.subnets["subnet1"].id  # Creates coupling!
}
```

### Correct Pattern

```hcl
# ✅ Always use remote_objects
resource "azurerm_private_endpoint" "pe" {
  subnet_id = var.remote_objects.vnets[var.client_config.landingzone_key]["vnet1"].subnets["subnet1"].id
}
```

---

## Dynamic Block Patterns

### Pattern 1: Optional Single Block

**Use when:** Resource has an optional nested block that appears 0 or 1 times.

```hcl
dynamic "identity" {
  for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

  content {
    type         = identity.value.type
    identity_ids = try(identity.value.identity_ids, null)
  }
}
```

**Why this works:**

- If `identity` is `null` → `for_each = []` → block not created
- If `identity` exists → `for_each = [object]` → block created once

### Pattern 2: Multiple Blocks from List

**Use when:** Resource accepts multiple instances of a block, configured as a list.

```hcl
dynamic "ip_restriction" {
  for_each = try(var.settings.ip_restrictions, [])

  content {
    ip_address = ip_restriction.value.ip_address
    action     = try(ip_restriction.value.action, "Allow")
    priority   = try(ip_restriction.value.priority, 100)
    name       = try(ip_restriction.value.name, null)
  }
}
```

**Configuration:**

```hcl
ip_restrictions = [
  { ip_address = "10.0.0.0/8", action = "Allow" },
  { ip_address = "192.168.1.0/24", action = "Deny", priority = 200 }
]
```

### Pattern 3: Multiple Blocks from Map

**Use when:** Each block needs a stable key for lifecycle management.

```hcl
dynamic "cors_rule" {
  for_each = try(var.settings.cors_rules, {})

  content {
    allowed_origins = cors_rule.value.allowed_origins
    allowed_methods = cors_rule.value.allowed_methods
    allowed_headers = try(cors_rule.value.allowed_headers, ["*"])
    exposed_headers = try(cors_rule.value.exposed_headers, [])
    max_age_in_seconds = try(cors_rule.value.max_age_in_seconds, 3600)
  }
}
```

**Configuration:**

```hcl
cors_rules = {
  default = {
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET", "POST"]
  }
  api = {
    allowed_origins = ["https://api.example.com"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
  }
}
```

**Benefits of Map:**

- Stable keys prevent resource recreation on reorder
- Easy to reference specific rules
- Clear semantic naming

### Pattern 4: Nested Dynamic Blocks

**Use when:** Block contains nested blocks.

```hcl
dynamic "site_config" {
  for_each = try(var.settings.site_config, null) == null ? [] : [var.settings.site_config]

  content {
    always_on = try(site_config.value.always_on, true)

    dynamic "ip_restriction" {
      for_each = try(site_config.value.ip_restrictions, [])

      content {
        ip_address = ip_restriction.value.ip_address
        action     = try(ip_restriction.value.action, "Allow")
      }
    }

    dynamic "cors" {
      for_each = try(site_config.value.cors, null) == null ? [] : [site_config.value.cors]

      content {
        allowed_origins = cors.value.allowed_origins
        support_credentials = try(cors.value.support_credentials, false)
      }
    }
  }
}
```

---

## CAF Naming Pattern

### Purpose

Automatically generate Azure-compliant resource names following CAF conventions.

### Implementation

```hcl
# In azurecaf_name.tf
resource "azurecaf_name" "grafana" {
  name          = var.settings.name
  resource_type = "azurerm_dashboard_grafana"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}

# In main resource file
resource "azurerm_dashboard_grafana" "grafana" {
  name = azurecaf_name.grafana.result  # Use generated name
  # ...
}
```

### What It Does

**Input:**

```hcl
global_settings = {
  prefixes = ["caf"]
  suffixes = ["001"]
  use_slug = true
}

settings = {
  name = "my-grafana"
}
```

**Output:**

```
grafana-caf-my-grafana-001-xxxxx
│       │   │          │   └─ Random suffix (5 chars)
│       │   │          └─ User suffix
│       │   └─ User-provided name
│       └─ User prefix
└─ CAF resource type slug
```

### Key Features

**Automatic Validation:**

- Length constraints (per Azure resource type)
- Character restrictions (alphanumeric, hyphens, etc.)
- Uniqueness (random suffix)

**Clean Input:**

```hcl
clean_input = true  # Removes invalid characters automatically
```

**Slug Control:**

```hcl
use_slug = true   # Adds CAF prefix (e.g., "grafana-")
use_slug = false  # Omits CAF prefix
```

### Common Resource Types

| Azure Resource  | `resource_type`                  | Default Slug |
| --------------- | -------------------------------- | ------------ |
| Resource Group  | `azurerm_resource_group`         | `rg-`        |
| Storage Account | `azurerm_storage_account`        | `st`         |
| Key Vault       | `azurerm_key_vault`              | `kv-`        |
| VNet            | `azurerm_virtual_network`        | `vnet-`      |
| Subnet          | `azurerm_subnet`                 | `snet-`      |
| NSG             | `azurerm_network_security_group` | `nsg-`       |
| AKS             | `azurerm_kubernetes_cluster`     | `aks-`       |
| Grafana         | `azurerm_dashboard_grafana`      | `grafana-`   |

### Critical Rule

**❌ NEVER include type prefixes in var.settings.name**

```hcl
# ❌ WRONG
name = "rg-my-resource-group"  # "rg-" will be duplicated!

# ✅ CORRECT
name = "my-resource-group"     # azurecaf adds "rg-" automatically
```

---

## Diagnostics Integration Pattern

### Purpose

Centralize logging configuration and automatically attach diagnostic settings to all resources.

### Architecture

```
┌──────────────────┐
│  Service Module  │
│  (e.g., Grafana) │
└────────┬─────────┘
         │
         │ calls
         ↓
┌────────────────────┐         ┌─────────────────────┐
│ Diagnostics Module │────────→│ Log Analytics       │
│ (../../diagnostics)│         │ Storage Account     │
│                    │         │ Event Hub           │
│ - Creates settings │         └─────────────────────┘
│ - Links destinations│
└────────────────────┘
```

### Implementation in Service Modules

```hcl
# In diagnostics.tf
module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})

  resource_id       = azurerm_dashboard_grafana.grafana.id
  resource_location = azurerm_dashboard_grafana.grafana.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

### Configuration in Examples

```hcl
# In configuration.tfvars
diagnostics = {
  diagnostic_log_analytics = {
    central_logs = {
      name = "central-logs"
      resource_group = { key = "ops_rg" }
    }
  }
}

monitoring = {
  grafana = {
    grafana1 = {
      name = "my-grafana"
      # ... other settings ...

      diagnostic_profiles = {
        operations = {
          name             = "operational_logs"
          definition_key   = "grafana"
          destination_type = "log_analytics"
          destination_key  = "central_logs"
        }
        audit = {
          name             = "audit_logs"
          definition_key   = "grafana_audit"
          destination_type = "storage"
          destination_key  = "audit_storage"
        }
      }
    }
  }
}
```

### What It Provides

**Automatic Configuration:**

- Log categories (audit, operational, metrics)
- Retention policies
- Destination routing
- Multiple destinations per resource

**Centralized Management:**

- Single diagnostics module for all services
- Consistent log structure
- Easy updates to log categories

### Benefits

- ✅ No duplicate diagnostic setting code
- ✅ Consistent logging across all resources
- ✅ Easy compliance auditing
- ✅ Supports multiple destinations

---

## Private Endpoint Pattern

### Purpose

Standardize private connectivity configuration across all services.

### Architecture

```
┌──────────────────┐
│  Service Module  │
│  (e.g., Grafana) │
└────────┬─────────┘
         │
         │ calls
         ↓
┌────────────────────────┐
│ Private Endpoint Module│
│ (../../networking/     │
│  private_endpoint)     │
│                        │
│ - Creates endpoint     │
│ - DNS integration      │
│ - Network policies     │
└────────────────────────┘
```

### Implementation

```hcl
# In private_endpoints.tf
module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_dashboard_grafana.grafana.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name

  # Subnet resolution (coalesce pattern)
  subnet_id = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ?
    try(
      each.value.subnet_id,
      var.remote_objects.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id
    ) :
    var.remote_objects.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id

  settings        = each.value
  global_settings = var.global_settings
  tags            = local.tags
  base_tags       = var.base_tags
  private_dns     = var.remote_objects.private_dns
  client_config   = var.client_config
}
```

### Configuration

```hcl
# In configuration.tfvars
private_dns = {
  grafana_private = {
    name = "privatelink.grafana.azure.com"
    resource_group = { key = "dns_rg" }
    vnet_links = {
      hub = { vnet_key = "hub_vnet" }
    }
  }
}

monitoring = {
  grafana = {
    grafana1 = {
      name = "my-grafana"
      # ... other settings ...

      private_endpoints = {
        pe1 = {
          name               = "grafana-pe"
          virtual_subnet_key = "private_endpoints_subnet"

          private_dns_zone = {
            key = "grafana_private"
          }

          private_service_connection = {
            name                 = "grafana-psc"
            is_manual_connection = false
            subresource_names    = ["grafana"]
          }
        }
      }
    }
  }
}
```

### Critical Rules

**❌ NEVER create azurerm_private_endpoint directly in service modules**

```hcl
# ❌ WRONG
resource "azurerm_private_endpoint" "pe" {
  name                = "grafana-pe"
  resource_group_name = local.resource_group_name
  # ...
}
```

**✅ ALWAYS use the private_endpoint submodule**

```hcl
# ✅ CORRECT
module "private_endpoint" {
  source = "../../networking/private_endpoint"
  # ...
}
```

### Benefits

- ✅ Consistent private endpoint configuration
- ✅ Automatic DNS integration
- ✅ Network policy management
- ✅ Single source of truth

---

## Tag Inheritance Pattern

### Purpose

Automatically propagate tags from global settings through resource groups to individual resources.

### Implementation

```hcl
# In locals.tf (MANDATORY pattern)
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }

  tags = var.base_tags ? merge(
    var.global_settings.tags,           # Global tags
    try(var.resource_group.tags, null), # Resource group tags
    local.module_tag,                    # Module identifier
    try(var.settings.tags, null)         # Resource-specific tags
  ) : merge(
    local.module_tag,                    # Always include module tag
    try(var.settings.tags, null)         # Resource-specific tags
  )
}
```

### Tag Hierarchy

```
global_settings.tags
    │
    ├─→ resource_group.tags
    │       │
    │       └─→ module_tag
    │               │
    │               └─→ settings.tags
    │
    └─→ FINAL TAGS on resource
```

### Example

**Configuration:**

```hcl
global_settings = {
  tags = {
    environment = "production"
    cost_center = "engineering"
  }
}

resource_groups = {
  app_rg = {
    name = "application"
    tags = {
      project = "customer-portal"
    }
  }
}

monitoring = {
  grafana = {
    grafana1 = {
      name = "portal-grafana"
      resource_group = { key = "app_rg" }
      tags = {
        component = "monitoring"
      }
    }
  }
}
```

**Resulting Tags:**

```hcl
{
  environment = "production"          # From global_settings
  cost_center = "engineering"         # From global_settings
  project     = "customer-portal"     # From resource_group
  module      = "grafana"             # From module_tag
  component   = "monitoring"          # From settings
}
```

### Tag Override

**Later tags override earlier tags:**

```hcl
global_settings = {
  tags = { environment = "production" }
}

settings = {
  tags = { environment = "development" }  # Overrides global
}

# Result: environment = "development"
```

### Benefits

- ✅ Consistent tagging across all resources
- ✅ Easy cost allocation
- ✅ Clear resource provenance
- ✅ Supports tag policies

---

## Resource Group Resolution Pattern

### Purpose

Resolve resource group reference regardless of how it's provided (key, ID, or name).

### Implementation

```hcl
# In root aggregator
resource_group = local.combined_objects_resource_groups[
  try(each.value.resource_group.lz_key, local.client_config.landingzone_key)
][
  try(each.value.resource_group.key, each.value.resource_group_key)
]

resource_group_name = local.combined_objects_resource_groups[
  try(each.value.resource_group.lz_key, local.client_config.landingzone_key)
][
  try(each.value.resource_group.key, each.value.resource_group_key)
].name
```

**Module locals:**

```hcl
# In module locals.tf
locals {
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}
```

### Configuration Options

```hcl
# Option 1: Key reference (preferred)
resource_group = {
  key = "app_rg"
}

# Option 2: Cross-landing-zone key
resource_group = {
  lz_key = "shared_services"
  key    = "network_rg"
}

# Option 3: Direct name (override)
resource_group_name = "explicit-rg-name"

# Option 4: Direct ID (rare)
resource_group = {
  id = "/subscriptions/.../resourceGroups/my-rg"
}
```

### Benefits

- ✅ Flexible configuration
- ✅ Supports all deployment scenarios
- ✅ Type-safe resolution
- ✅ Clear precedence order

---

## Backward Compatibility Pattern

### Purpose

Maintain compatibility with old configuration formats while supporting new ones.

### Implementation

```hcl
# Support both old and new attribute names
sku_name = try(
  var.settings.sku_name,              # New name (preferred)
  var.settings.sku,                   # Old name (deprecated)
  "Standard"                           # Default
)

# Support both resource_group_key and resource_group.key
resource_group_key = try(
  each.value.resource_group.key,      # New nested format
  each.value.resource_group_key       # Old flat format
)

# Support both identity_ids and managed_identity_keys
identity_ids = coalesce(
  try(var.settings.identity_ids, null),              # Direct IDs
  try([
    for key in var.settings.managed_identity_keys :  # Keys to resolve
    var.remote_objects.managed_identities[
      try(var.settings.lz_key, var.client_config.landingzone_key)
    ][key].id
  ], null)
)
```

### Deprecation Strategy

**Phase 1: Add new attribute with fallback**

```hcl
new_attribute = try(
  var.settings.new_attribute,
  var.settings.old_attribute,
  default_value
)
```

**Phase 2: Document deprecation**

```hcl
# DEPRECATED: old_attribute is deprecated, use new_attribute instead
new_attribute = try(
  var.settings.new_attribute,
  var.settings.old_attribute,  # Remove in v5.0
  default_value
)
```

**Phase 3: Remove old attribute (major version)**

```hcl
new_attribute = try(var.settings.new_attribute, default_value)
```

### Benefits

- ✅ No breaking changes in minor versions
- ✅ Smooth migration path
- ✅ Clear deprecation timeline
- ✅ Backward compatibility maintained

---

## Testing Pattern

### Purpose

Examples serve as both documentation and automated tests.

### Structure

```
examples/
└── category/
    └── service_name/
        ├── 100-simple/              # Minimal configuration
        │   └── configuration.tfvars
        ├── 200-networking/          # With private endpoints
        │   └── configuration.tfvars
        └── 300-advanced/            # All features
            └── configuration.tfvars
```

### Testing Flow

```
┌────────────────────────┐
│ configuration.tfvars   │
└───────────┬────────────┘
            │
            ↓
┌────────────────────────┐
│ terraform test         │
│ - Mock providers       │
│ - Validate syntax      │
│ - Check references     │
└───────────┬────────────┘
            │
            ↓
┌────────────────────────┐
│ GitHub Actions         │
│ - Run for all examples │
│ - Block on failure     │
└────────────────────────┘
```

### Test Configuration

```hcl
# In .github/workflows/standalone-scenarios.json
{
  "config_files": [
    "monitoring/grafana/100-simple",
    "monitoring/grafana/200-networking",
    "monitoring/grafana/300-advanced"
  ]
}
```

### Running Tests Locally

```bash
# Test specific example
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file="./monitoring/grafana/100-simple/configuration.tfvars" \
  -verbose

# Test all examples in a category
find examples/monitoring -name "configuration.tfvars" | \
  xargs -I {} terraform -chdir=examples test \
    -test-directory=./tests/mock \
    -var-file="{}" \
    -verbose
```

### Benefits

- ✅ Examples stay current (CI enforced)
- ✅ Documentation is always accurate
- ✅ Fast validation (no real Azure resources)
- ✅ Easy to add new test cases

---

## Pattern Summary

| Pattern                       | Purpose                      | When to Use                              |
| ----------------------------- | ---------------------------- | ---------------------------------------- |
| **Coalesce**                  | Flexible resource references | Always for dependencies                  |
| **Remote Objects**            | Decouple modules             | Always for module outputs                |
| **Dynamic Blocks**            | Optional nested config       | Optional resource blocks                 |
| **CAF Naming**                | Compliant resource names     | All named resources                      |
| **Diagnostics**               | Centralized logging          | All resources with diagnostics           |
| **Private Endpoints**         | Network isolation            | Services supporting private connectivity |
| **Tag Inheritance**           | Consistent tagging           | All resources                            |
| **Resource Group Resolution** | Flexible RG references       | All resources                            |
| **Backward Compatibility**    | Non-breaking changes         | Attribute renames/deprecations           |
| **Testing**                   | Validated examples           | All modules                              |

---

## Next Steps

- [Module Development Guide](./MODULE_DEVELOPMENT.md) - Create new modules
- [Contributing Guide](./CONTRIBUTING.md) - PR process and guidelines
- [Architecture Overview](../architecture/OVERVIEW.md) - Framework overview

---

**Last Updated**: November 2025  
**Framework Version**: 3-Layer Architecture  
**Terraform Version**: >= 1.9
