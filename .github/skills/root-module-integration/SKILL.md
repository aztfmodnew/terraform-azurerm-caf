---
name: root-module-integration
description: Complete 8-step workflow for integrating a new module into the Azure CAF root framework. Use this skill after creating a module to wire it into the root aggregator, set up combined_objects, create examples, and integrate with CI/CD.
---

# Root Module Integration Workflow

After creating a module, follow this 8-step process to integrate it into the root framework.

## Overview

Integration connects your module to the framework's dependency resolution system, making it:
- ✅ Accessible from examples
- ✅ Available in combined_objects for cross-module references
- ✅ Tested in CI/CD pipelines
- ✅ Documented with working examples

## Step-by-Step Integration

### Step 1: Create Root Aggregator File

**Location**: `/<category>_<module_names>.tf` (plural form)

**Example**: For `modules/cache/managed_redis/` → `/cache_managed_redis.tf`

**Template**:

```hcl
#
# Managed Redis (Azure Cache for Redis)
#

module "managed_redis" {
  source   = "./modules/cache/managed_redis"
  for_each = local.cache.managed_redis

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value

  # Pass all dependencies needed by the module
  remote_objects = {
    resource_groups     = local.combined_objects_resource_groups
    vnets              = local.combined_objects_vnets
    virtual_subnets    = local.combined_objects_virtual_subnets
    managed_identities = local.combined_objects_managed_identities
    # Add other dependencies as needed by the module
  }

  # Standard dependencies (if module uses them)
  base_tags       = local.global_settings.inherit_tags
  resource_groups = local.combined_objects_resource_groups
  location        = try(each.value.location, local.global_settings.regions[local.global_settings.default_region])
}

output "managed_redis" {
  value = module.managed_redis
}
```

**Key Points**:
- File name uses plural (e.g., `managed_redis` not `managed_redi`)
- Module source path must be correct relative path
- `for_each` uses local variable extraction (next step)
- Pass ALL dependencies via `remote_objects`
- Always include output block

**Common Mistakes**:
- ❌ Wrong source path (`./modules/managed_redis` instead of `./modules/cache/managed_redis`)
- ❌ Missing remote_objects dependencies
- ❌ Forgetting output block
- ❌ Using singular form in file name

---

### Step 2: Add Variable to /variables.tf

**Location**: `/variables.tf`

**Find the appropriate category section** and add your variable:

```hcl
#
# Cache services
#

variable "cache" {
  default = {}
}
```

**Rules**:
- Variable name matches the category used in locals
- Always provide `default = {}`
- Add to existing category section if available
- Create new category section if needed

**Example for new category**:

```hcl
#
# Chaos Studio
#

variable "chaos_studio" {
  default = {}
}
```

---

### Step 3: Add Module to /locals.tf

**Location**: `/locals.tf`

**Find or create the category locals block**:

```hcl
cache = {
  managed_redis = try(var.cache.managed_redis, {})
  # other cache services...
}
```

**Pattern**:
- Extract from `var.<category>.<module_name>`
- Use `try()` with empty map `{}` as fallback
- Keep alphabetically ordered within category

**Full example**:

```hcl
locals {
  # ... existing locals ...

  cache = {
    app_configuration              = try(var.cache.app_configuration, {})
    managed_redis                  = try(var.cache.managed_redis, {})
    redis_cache                    = try(var.cache.redis_cache, {})
  }

  chaos_studio = {
    chaos_studio_targets      = try(var.chaos_studio.chaos_studio_targets, {})
    chaos_studio_capabilities = try(var.chaos_studio.chaos_studio_capabilities, {})
    chaos_studio_experiments  = try(var.chaos_studio.chaos_studio_experiments, {})
  }

  # ... more locals ...
}
```

---

### Step 4: Add to /locals.combined_objects.tf

**Location**: `/locals.combined_objects.tf`

**Purpose**: Merge module outputs with remote objects and data sources for cross-module references.

**Pattern**:

```hcl
combined_objects_managed_redis = merge(
  tomap(
    {
      for key, value in module.managed_redis : key => value
    }
  ),
  tomap(
    {
      for key, value in try(var.remote_objects.managed_redis, {}) : key => value
    }
  ),
  tomap(
    {
      for key, value in try(data.terraform_remote_state.remote[local.backend_type].outputs.objects[local.current_landingzone_key].managed_redis, {}) : key => value
    }
  )
)
```

**Template Breakdown**:
1. **Module outputs**: Current landing zone resources
2. **Remote objects**: Cross-landing-zone references
3. **Remote state**: Data sources from other states

**Add to combined_objects map**:

```hcl
combined_objects = {
  # ... existing entries ...
  managed_redis = local.combined_objects_managed_redis
  # ... more entries ...
}
```

**Keep alphabetically ordered** for maintainability.

---

### Step 5: Create Deployment Example

**Location**: `/examples/<category>/<service_name>/100-simple-<service>/configuration.tfvars`

**Directory Structure**:

```
/examples
└── /<category>
    └── /<service_name>
        ├── /100-simple-<service>
        │   ├── configuration.tfvars
        │   └── README.md
        └── /200-<service>-private-endpoint  (optional)
            ├── configuration.tfvars
            └── README.md
```

**Example Template**:

```hcl
# Global settings (MANDATORY)
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5  # For unique naming
}

# Resource groups (MANDATORY)
resource_groups = {
  test_rg = {
    name = "managed-redis-test-1"  # No prefix - azurecaf adds it
  }
}

# Service configuration
cache = {
  managed_redis = {
    redis1 = {
      name = "test-redis-001"
      
      # Key-based reference (preferred)
      resource_group = {
        key = "test_rg"
      }
      
      # Service-specific settings
      sku_name = "Standard"
      family   = "C"
      capacity = 1
      
      # Optional settings with try() patterns
      minimum_tls_version           = "1.2"
      public_network_access_enabled = false
      
      tags = {
        environment = "dev"
        purpose     = "example"
      }
    }
  }
}
```

**Key Rules**:
- Use **key-based references** (`resource_group = { key = "test_rg" }`)
- **NO azurecaf prefixes** in names (e.g., "managed-redis-test-1" not "rg-managed-redis-test-1")
- Include `global_settings` with `random_length`
- File MUST be named `configuration.tfvars`
- Follow numbered directory convention (100-xxx, 200-xxx)

---

### Step 6: Create Mock Test Example

**Location**: `/examples/tests/<category>/<service_name>/100-simple-<service>-mock/configuration.tfvars`

**Purpose**: Enable mock testing without Azure resources.

**Key Differences from Deployment Example**:
- Uses **direct IDs** instead of key-based references
- Stored in `/examples/tests/` directory
- Appends `-mock` suffix to directory name

**Example Template**:

```hcl
# Same global_settings and resource_groups as deployment example
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  test_rg = {
    name = "managed-redis-test-1"
  }
}

# Service configuration with DIRECT IDs
cache = {
  managed_redis = {
    redis1 = {
      name = "test-redis-001"
      
      # Direct ID (for mock testing)
      resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-managed-redis-test-1-xxxxx"
      
      # If service needs subnet
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-redis"
      
      # Same service configuration
      sku_name = "Standard"
      family   = "C"
      capacity = 1
      
      tags = {
        environment = "mock"
        purpose     = "testing"
      }
    }
  }
}
```

**Pattern for Direct IDs**:
```hcl
# Resource Group
resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-<name>-<random>"

# Subnet
subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-<name>/subnets/snet-<name>"

# Managed Identity
identity_ids = [
  "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-<name>"
]
```

---

### Step 7: Add to CI/CD Workflow

**Location**: `.github/workflows/standalone-scenarios*.json`

**Workflow Files**:
- `standalone-scenarios.json` - Main scenarios (monitoring, storage, cognitive)
- `standalone-compute.json` - Compute resources (VMs, AKS, containers)
- `standalone-networking.json` - Networking resources
- `standalone-dataplat.json` - Data platform resources
- `standalone-scenarios-additional.json` - Additional/overflow scenarios

**Steps**:

1. **Determine correct workflow file** based on category
2. **Find alphabetical position** in the config_files array
3. **Add example path** (relative to /examples/)

**Example**:

```json
{
  "config_files": [
    "monitoring/100-service-health-alerts",
    "monitoring/101-monitor-action-groups",
    "cache/managed_redis/100-simple-managed-redis",  // ← Add here
    "netapp/101-nfs",
    "networking/application_gateway/100-simple"
  ]
}
```

**Verification**:
```bash
# Check the path matches
ls examples/cache/managed_redis/100-simple-managed-redis/configuration.tfvars

# Validate JSON syntax
cat .github/workflows/standalone-scenarios.json | jq '.'
```

---

### Step 8: Test the Integration

#### A. Run Mock Test

```bash
cd examples
terraform test \
  -test-directory=./tests/mock \
  -var-file=./cache/managed_redis/100-simple-managed-redis/configuration.tfvars \
  -verbose
```

**Alternative**: Use `terraform -chdir=examples test ...` for single command execution.

**Expected Output**:
```
tests/mock/e2e_plan.tftest.hcl... in progress
  run "test_plan"... pass
tests/mock/e2e_plan.tftest.hcl... tearing down
tests/mock/e2e_plan.tftest.hcl... pass

Success! 1 passed, 0 failed.
```

#### B. Test Real Deployment (Optional)

```bash
# Verify Azure subscription first (MANDATORY)
az account show --query "{subscriptionId:id, name:name}" -o table
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Test with deployment example
cd examples
terraform_with_var_files \
  --dir /cache/managed_redis/100-simple-managed-redis/ \
  --action plan \
  --auto auto \
  --workspace test
```

#### C. Verify Combined Objects

Create a test example that references your module:

```hcl
# In another module's example
some_other_service = {
  instance1 = {
    managed_redis = {
      key    = "redis1"  # References your module
      lz_key = "current"  # Or remote landing zone
    }
  }
}
```

---

## Integration Checklist

Use this checklist to verify complete integration:

### Module Files
- [ ] Module created in `modules/<category>/<module_name>/`
- [ ] Module follows standard structure (providers, variables, locals, outputs)
- [ ] Module tested with mock tests

### Root Integration
- [ ] `/category_module_names.tf` - Root aggregator created
- [ ] `/variables.tf` - Variable added for category
- [ ] `/locals.tf` - Module added to category locals
- [ ] `/locals.combined_objects.tf` - combined_objects entry added
- [ ] Output block exists in aggregator file

### Examples
- [ ] Deployment example created: `/examples/<category>/<service>/100-*/configuration.tfvars`
- [ ] Examples use key-based references
- [ ] Examples include global_settings with random_length
- [ ] Resource names WITHOUT azurecaf prefixes

### CI/CD
- [ ] Added to appropriate workflow JSON file
- [ ] Path is correct (relative to /examples/)
- [ ] Alphabetically ordered in array
- [ ] JSON syntax validated

### Testing
- [ ] Mock test passes successfully
- [ ] Deployment plan generates without errors (if tested)
- [ ] Combined_objects resolution works (if tested with dependent module)

---

## Common Integration Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Module not found** | "No module call named..." | Check Step 1: aggregator file exists and source path correct |
| **Unknown variable** | "Unknown variable: var.category" | Check Step 2: variable added to variables.tf |
| **Key doesn't exist** | "The given key does not identify..." | Check Step 3: locals.tf has correct extraction path |
| **Combined objects not found** | "Unknown local: combined_objects_*" | Check Step 4: locals.combined_objects.tf has entry |
| **Example fails** | Test errors | Check Step 5 & 6: Example syntax and references |
| **CI fails** | Workflow doesn't find example | Check Step 7: Path is correct in JSON |
| **Output not found** | "Output not found" | Check Step 1: output block exists in aggregator |
| **Circular dependency** | "Cycle error" | Review module dependencies, use depends_on if needed |

---

## Validation Commands

### Check Module Source Path
```bash
# From root directory
ls modules/<category>/<module_name>/*.tf
```

### Verify Variable Exists
```bash
grep "variable \"<category>\"" variables.tf
```

### Check Locals Entry
```bash
grep "<module_name>" locals.tf
```

### Verify Combined Objects
```bash
grep "combined_objects_<module_name>" locals.combined_objects.tf
```

### Test Example Path
```bash
ls examples/<category>/<service>/100-*/configuration.tfvars
ls examples/tests/<category>/<service>/100-*-mock/configuration.tfvars
```

### Validate Workflow Integration
```bash
cat .github/workflows/standalone-*.json | jq '.config_files[]' | grep "<category>"
```

---

## Integration Pattern Summary

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Create /category_module_names.tf                        │
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
│ 5. Create deployment example                                │
│    → Shows production usage with key-based references       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. Create mock test example                                 │
│    → Enables syntax testing with direct IDs                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. Add to CI/CD workflow                                    │
│    → Enables automated testing                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. Test integration                                         │
│    → Mock test + optional real deployment                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ ✅ Module fully integrated and available for use            │
│    → Can be referenced via combined_objects by other modules│
└─────────────────────────────────────────────────────────────┘
```

---

## Next Steps After Integration

Once integration is complete:

1. **Create Advanced Examples** (200-xxx, 300-xxx)
   - Private endpoint integration
   - Managed identity configuration
   - Complex networking scenarios

2. **Add Documentation**
   - Module README.md
   - Example README.md files
   - Update repository documentation

3. **Test Cross-Module References**
   - Create examples that use combined_objects
   - Verify dependency resolution works
   - Test cross-landing-zone scenarios

4. **Monitor CI/CD**
   - Watch workflow runs
   - Fix any test failures
   - Optimize test execution time

---

## Tips for Success

- **Work systematically** - Complete each step before moving to the next
- **Test incrementally** - Run mock tests after each major change
- **Verify paths** - Double-check all relative paths and file locations
- **Follow conventions** - Use established patterns from existing modules
- **Keep consistent** - Match naming and structure of similar modules
- **Document issues** - Note any problems for future improvements
- **Ask for review** - Get feedback before marking integration complete

---

## Related Skills

- **module-creation** - Create the module before integrating
- **mock-testing** - Test the integrated module
- **azure-schema-validation** - Validate resource schemas
- **example-creation** - Create comprehensive examples (future skill)
