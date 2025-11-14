# Module Development Guide

> **Complete guide to creating new CAF Terraform modules**

This guide walks you through creating a new Azure resource module for the terraform-azurerm-caf framework, from initial setup to integration with the root orchestrator.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Module Creation Workflow](#module-creation-workflow)
3. [Step-by-Step Guide](#step-by-step-guide)
4. [Standard Module Files](#standard-module-files)
5. [Integration with Root](#integration-with-root)
6. [Testing Your Module](#testing-your-module)
7. [Documentation](#documentation)
8. [Common Patterns](#common-patterns)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before creating a new module, ensure you have:

- ✅ Access to Azure provider documentation for your target resource
- ✅ Understanding of the [3-layer architecture](../architecture/OVERVIEW.md)
- ✅ Familiarity with CAF naming conventions
- ✅ MCP Terraform tools for schema validation (recommended)
- ✅ Local development environment with Terraform >= 1.9

---

## Module Creation Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Plan Module Structure                                    │
│    - Determine category (compute, networking, etc.)        │
│    - Identify Azure resource type                          │
│    - Check for subresources/child resources                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Create Module Directory Structure                       │
│    - Create modules/category/service_name/                 │
│    - Initialize standard files                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Implement Module Resources                              │
│    - Define main resource with ALL attributes              │
│    - Add CAF naming                                        │
│    - Integrate diagnostics (if supported)                  │
│    - Add private endpoints (if supported)                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Wire into Root Orchestrator                             │
│    - Create aggregator file (category_service_names.tf)    │
│    - Add variable to variables.tf                          │
│    - Add locals entry to locals.tf                         │
│    - Add combined_objects entry                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Create Examples                                          │
│    - 100-simple (basic configuration)                      │
│    - 200-intermediate (with networking)                    │
│    - 300-advanced (all features)                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. Test and Document                                        │
│    - Add to workflow JSON for CI/CD                        │
│    - Test with terraform test                              │
│    - Update documentation                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Guide

### Step 1: Plan Your Module

**Determine the category:**

- `compute/` - VMs, AKS, Container Apps, Batch
- `networking/` - VNets, NSGs, Firewalls, Load Balancers
- `cognitive_services/` - AI Services, OpenAI
- `databases/` - SQL, PostgreSQL, Cosmos DB
- `monitoring/` - Grafana, Log Analytics, Application Insights
- `security/` - Key Vault, Managed Identity
- Other categories as appropriate

**Example Decision:**

```
Resource: Azure Managed Grafana
Category: monitoring
Service: grafana
Module Path: modules/monitoring/grafana/
```

### Step 2: Create Directory Structure

```bash
# Create module directory
mkdir -p modules/monitoring/grafana

# Create standard files
cd modules/monitoring/grafana
touch providers.tf variables.tf locals.tf outputs.tf
touch azurecaf_name.tf grafana.tf diagnostics.tf private_endpoints.tf
```

### Step 3: Implement Standard Files

#### 3.1 providers.tf

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 2.0"
    }
  }
}
```

#### 3.2 variables.tf

**Use the standard variable pattern:**

```hcl
variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
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

variable "resource_group_name" {
  description = "Resource group name (optional, overrides resource_group.name)."
  type        = string
  default     = null
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for cross-module dependencies."
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Map of private endpoint configurations."
  type        = any
  default     = {}
}
```

#### 3.3 locals.tf (MANDATORY Pattern)

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
    try(var.settings.tags, null)
  )

  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}
```

#### 3.4 azurecaf_name.tf

```hcl
resource "azurecaf_name" "grafana" {
  name          = var.settings.name
  resource_type = "azurerm_dashboard_grafana"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
```

**⚠️ Important:** Check the azurecaf provider documentation for the correct `resource_type` value.

#### 3.5 Main Resource File (grafana.tf)

**Best Practice:** Validate ALL attributes using MCP Terraform tools before implementing.

```hcl
# Source: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana
# Validation: MCP Terraform (providerDocID: 10170113) - All attributes validated
resource "azurerm_dashboard_grafana" "grafana" {
  name                = azurecaf_name.grafana.result
  resource_group_name = local.resource_group_name
  location            = local.location

  # Required arguments
  grafana_major_version = try(var.settings.grafana_major_version, 11)

  # Optional arguments - use try() with null fallback
  api_key_enabled                        = try(var.settings.api_key_enabled, false)
  auto_generated_domain_name_label_scope = try(var.settings.auto_generated_domain_name_label_scope, "TenantReuse")
  deterministic_outbound_ip_enabled      = try(var.settings.deterministic_outbound_ip_enabled, false)
  public_network_access_enabled          = try(var.settings.public_network_access_enabled, true)
  sku                                    = try(var.settings.sku, "Standard")
  zone_redundancy_enabled                = try(var.settings.zone_redundancy_enabled, false)

  # Dynamic blocks for nested objects
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type = identity.value.type
      identity_ids = contains(["userassigned", "systemassigned, userassigned"], lower(identity.value.type)) ? coalesce(
        try(identity.value.identity_ids, null),
        try([
          for key in try(identity.value.managed_identity_keys, []) :
          var.remote_objects.managed_identities[try(identity.value.lz_key, var.client_config.landingzone_key)][key].id
        ], null)
      ) : null
    }
  }

  # Timeouts
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, "30m")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }

  tags = merge(local.tags, try(var.settings.tags, null))
}
```

**Key Patterns:**

- ✅ Use `try(var.settings.attribute, default_value)` for optional attributes
- ✅ Use `dynamic` blocks for nested objects with `for_each`
- ✅ Implement coalesce pattern for dependency resolution
- ✅ Always merge tags with `local.tags`

#### 3.6 diagnostics.tf (If Service Supports Diagnostics)

```hcl
module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_dashboard_grafana.grafana.id
  resource_location = azurerm_dashboard_grafana.grafana.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

**⚠️ Path Verification:**

```bash
# From module directory, verify path resolves correctly
realpath ../../diagnostics
# Expected: /path/to/repo/modules/diagnostics
```

#### 3.7 private_endpoints.tf (If Service Supports Private Endpoints)

```hcl
module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_dashboard_grafana.grafana.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name

  # Subnet resolution with coalesce pattern
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

#### 3.8 outputs.tf

```hcl
output "id" {
  value       = azurerm_dashboard_grafana.grafana.id
  description = "The ID of the Grafana dashboard"
}

output "name" {
  value       = azurecaf_name.grafana.result
  description = "The name of the Grafana dashboard"
}

output "endpoint" {
  value       = azurerm_dashboard_grafana.grafana.endpoint
  description = "The endpoint URL of the Grafana dashboard"
}

# Sensitive outputs
output "grafana" {
  value       = azurerm_dashboard_grafana.grafana
  description = "Full Grafana resource object"
  sensitive   = true
}
```

---

## Integration with Root

### Step 4.1: Create Root Aggregator File

Create `/grafana.tf` (or appropriate category file):

```hcl
module "grafana" {
  source              = "./modules/monitoring/grafana"
  for_each            = local.monitoring.grafana

  client_config       = local.client_config
  global_settings     = local.global_settings
  settings            = each.value
  location            = try(each.value.location, null)
  base_tags           = local.global_settings.inherit_tags

  # Resource group resolution with coalesce
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name

  private_endpoints   = try(each.value.private_endpoints, {})

  # Dependencies
  remote_objects = {
    vnets              = local.combined_objects_networking
    virtual_subnets    = local.combined_objects_virtual_subnets
    private_dns        = local.combined_objects_private_dns
    diagnostics        = local.combined_diagnostics
    resource_groups    = local.combined_objects_resource_groups
    managed_identities = local.combined_objects_managed_identities
  }
}

output "grafana" {
  value = module.grafana
}
```

### Step 4.2: Add to variables.tf

```hcl
variable "monitoring" {
  description = "Configuration for monitoring services"
  default     = {}
}
```

### Step 4.3: Add to locals.tf

```hcl
locals {
  monitoring = {
    grafana = try(var.monitoring.grafana, {})
  }
}
```

### Step 4.4: Add to locals.combined_objects.tf

```hcl
combined_objects_grafana = merge(
  tomap({ (local.client_config.landingzone_key) = module.grafana }),
  lookup(var.remote_objects, "grafana", {}),
  lookup(var.data_sources, "grafana", {})
)
```

### Step 4.5: Add to local.remote_objects.tf

```hcl
locals {
  remote_objects = {
    # ... existing entries ...
    grafana = try(local.combined_objects_grafana, null)
  }
}
```

---

## Testing Your Module

### Step 5: Create Examples

Create directory structure:

```bash
mkdir -p examples/monitoring/grafana/100-simple-grafana
```

Create `examples/monitoring/grafana/100-simple-grafana/configuration.tfvars`:

```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  grafana_rg = {
    name = "grafana-test-1"  # No "rg-" prefix!
  }
}

monitoring = {
  grafana = {
    grafana1 = {
      name                  = "grafana-test-1"
      grafana_major_version = 11
      sku                   = "Standard"

      resource_group = {
        key = "grafana_rg"
      }

      identity = {
        type = "SystemAssigned"
      }

      tags = {
        environment = "dev"
        purpose     = "example"
      }
    }
  }
}
```

### Step 6: Add to CI/CD

Edit `.github/workflows/standalone-scenarios.json`:

```json
{
  "config_files": [
    "existing/examples",
    "monitoring/grafana/100-simple-grafana",
    "more/examples"
  ]
}
```

### Step 7: Test Locally

```bash
# From examples directory
cd /path/to/terraform-azurerm-caf/examples

# Run Terraform test
terraform test \
  -test-directory=./tests/mock \
  -var-file="./monitoring/grafana/100-simple-grafana/configuration.tfvars" \
  -verbose
```

---

## Documentation

### Generate Module Documentation

The documentation is auto-generated from module metadata. After creating your module:

```bash
# Regenerate documentation
python3 scripts/deepwiki/generate_mkdocs_auto.py --no-force-nav

# Verify module appears in docs/modules/
ls -la docs/modules/monitoring/
```

### Module README (Optional)

While the framework auto-generates documentation, you can add a README for complex modules:

```markdown
# Azure Managed Grafana Module

This module deploys Azure Managed Grafana instances with support for:

- System-assigned and user-assigned managed identities
- Private endpoint integration
- Azure Monitor Workspace integrations
- Diagnostic settings

## Usage

See `examples/monitoring/grafana/` for usage examples.

## Supported Features

- ✅ CAF naming conventions
- ✅ Diagnostics integration
- ✅ Private endpoints
- ✅ Zone redundancy
- ✅ SMTP configuration
```

---

## Common Patterns

### Pattern 1: Optional Single Block

```hcl
dynamic "identity" {
  for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

  content {
    type         = identity.value.type
    identity_ids = try(identity.value.identity_ids, null)
  }
}
```

### Pattern 2: Multiple Blocks from List

```hcl
dynamic "ip_restriction" {
  for_each = try(var.settings.ip_restrictions, [])

  content {
    ip_address = ip_restriction.value.ip_address
    name       = try(ip_restriction.value.name, null)
  }
}
```

### Pattern 3: Multiple Blocks from Map

```hcl
dynamic "rule" {
  for_each = try(var.settings.rules, {})

  content {
    name     = rule.key
    priority = rule.value.priority
    action   = rule.value.action
  }
}
```

### Pattern 4: Dependency Resolution (Coalesce)

```hcl
# Resolve managed identity ID
identity_ids = coalesce(
  try(var.settings.identity_ids, null),
  try([
    for key in var.settings.managed_identity_keys :
    var.remote_objects.managed_identities[try(var.settings.lz_key, var.client_config.landingzone_key)][key].id
  ], null)
)
```

### Pattern 5: Backward Compatibility

```hcl
# Support both old and new attribute names
sku_name = try(
  var.settings.sku_name,      # New name
  var.settings.sku,           # Old name
  "Standard"                   # Default
)
```

---

## Troubleshooting

### Issue: Module Not Found in Documentation

**Symptoms:** Module doesn't appear in MkDocs navigation

**Solutions:**

1. Verify module depth: `modules/category/service_name/`
2. Regenerate docs: `python3 scripts/deepwiki/generate_mkdocs_auto.py`
3. Check for `.tf` files in module directory

### Issue: Relative Path Errors

**Symptoms:** `Error: Module not found: ../../diagnostics`

**Solutions:**

```bash
# From module directory
realpath ../../diagnostics
# Should output: /path/to/repo/modules/diagnostics

# If incorrect, check your depth:
pwd
# Should be: /path/to/repo/modules/category/service_name
```

### Issue: "Unknown Variable" in Examples

**Symptoms:** `Error: Unknown variable "monitoring"`

**Solutions:**

1. Verify variable added to `/variables.tf`
2. Verify locals entry in `/locals.tf`
3. Check example variable name matches root variable

### Issue: Circular Dependency

**Symptoms:** `Error: Cycle: module.resource_a, module.resource_b`

**Solutions:**

- Never reference sibling modules directly in module code
- Use `remote_objects` for cross-module dependencies
- Pass dependencies through root aggregator

### Issue: CAF Naming Failures

**Symptoms:** Resource name too long or invalid characters

**Solutions:**

1. Don't include prefixes in `var.settings.name` (azurecaf adds them)
2. Verify `resource_type` is correct in `azurecaf_name.tf`
3. Check azurecaf provider docs for resource-specific rules

---

## Checklist

Before submitting a PR for your new module:

- [ ] Module structure follows standards (`providers.tf`, `variables.tf`, `locals.tf`, etc.)
- [ ] All resource attributes validated (preferably with MCP Terraform)
- [ ] CAF naming implemented correctly
- [ ] Diagnostics integration added (if supported)
- [ ] Private endpoints integration added (if supported)
- [ ] Standard variables pattern used
- [ ] Standard locals pattern implemented
- [ ] Outputs defined for ID, name, and key attributes
- [ ] Root aggregator file created
- [ ] Variables added to `/variables.tf`
- [ ] Locals entry added to `/locals.tf`
- [ ] Combined objects entry added to `/locals.combined_objects.tf`
- [ ] Remote objects entry added to `/local.remote_objects.tf`
- [ ] At least one example created (100-simple)
- [ ] Example added to workflow JSON
- [ ] Local testing with `terraform test` passed
- [ ] Documentation generated successfully
- [ ] No hardcoded values (use variables)
- [ ] Tags follow standard pattern
- [ ] All code in English

---

## Next Steps

- [Design Patterns](../architecture/PATTERNS.md) - Deep dive into implementation patterns
- [Contributing Guide](./CONTRIBUTING.md) - PR process and guidelines
- [Architecture Overview](../architecture/OVERVIEW.md) - Understand the framework

---

**Last Updated**: November 2025  
**Framework Version**: 3-Layer Architecture  
**Terraform Version**: >= 1.9
