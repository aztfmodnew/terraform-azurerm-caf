---
name: diagnostics-integration
description: Add Azure Monitor diagnostic settings to existing Terraform modules. Use this skill when adding monitoring, logging, or diagnostics capabilities to a module that supports Azure diagnostic settings.
---

# Diagnostics Integration for Azure CAF Modules

Add Azure Monitor diagnostic settings to modules for comprehensive logging and monitoring.

## When to Use This Skill

Use this skill when:
- Creating a new module for a resource that supports diagnostic settings
- Adding diagnostics to an existing module
- A user asks to "add monitoring" or "enable logging"
- Implementing compliance requirements (e.g., log all operations)

## Azure Services That Support Diagnostics

Most Azure services support diagnostic settings. Common examples:
- ✅ Storage Accounts
- ✅ Key Vaults
- ✅ SQL Databases
- ✅ App Services
- ✅ AKS Clusters
- ✅ Azure Cache for Redis
- ✅ Cognitive Services
- ✅ Container Apps
- ✅ Virtual Networks
- ✅ Application Gateways

## Verification: Does the Service Support Diagnostics?

**Check Azure Provider Documentation**:
```
Resource: azurerm_<resource_name>
Look for: azurerm_monitor_diagnostic_setting referencing this resource type
```

Or search Azure documentation for "diagnostic settings for [service name]".

---

## Step-by-Step Implementation

### Step 1: Check if Module Already Supports Diagnostics

```bash
# Check if diagnostics.tf exists
ls modules/<category>/<module_name>/diagnostics.tf

# Check if variable exists
grep "diagnostics" modules/<category>/<module_name>/variables.tf
```

If the file exists, the module already supports diagnostics. Skip to Step 6 (Creating Examples).

---

### Step 2: Create diagnostics.tf File

**Location**: `modules/<category>/<module_name>/diagnostics.tf`

**Standard Template**:

```hcl
#
# Diagnostics settings
#

module "diagnostics" {
  source = "../../diagnostics"
  count  = var.diagnostics != null ? 1 : 0

  resource_id       = <resource_reference>.id
  resource_location = try(var.settings.location, local.location)
  diagnostics       = var.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

**Key Elements**:
- **Source**: Always `../../diagnostics` (relative path from module)
- **Count**: Only create if diagnostics are configured
- **resource_id**: Reference to the main resource's ID
- **resource_location**: Use module's location logic
- **diagnostics**: Pass through diagnostics configuration
- **profiles**: Optional diagnostic profiles

**Examples by Resource Type**:

```hcl
# Storage Account
resource_id = azurerm_storage_account.storage.id

# Key Vault
resource_id = azurerm_key_vault.keyvault.id

# Managed Redis
resource_id = azurerm_redis_cache.redis.id

# Container App
resource_id = azurerm_container_app.app.id

# AKS Cluster
resource_id = azurerm_kubernetes_cluster.aks.id

# Application Gateway
resource_id = azurerm_application_gateway.agw.id
```

---

### Step 3: Add Diagnostics Variable

**Location**: `modules/<category>/<module_name>/variables.tf`

**Add this variable**:

```hcl
variable "diagnostics" {
  description = "Diagnostic settings for the resource. Supports Log Analytics, Storage Account, and Event Hub destinations."
  default     = null
}
```

**Standard Pattern**:
- Always optional (`default = null`)
- Generic description mentioning supported destinations
- No type constraint (uses `any` implicitly)

---

### Step 4: Verify Relative Path

The diagnostics module path must be correct based on module depth.

**Standard Module Structure** (depth 2):
```
modules/
└── <category>/
    └── <module_name>/
        └── diagnostics.tf → source = "../../diagnostics"
```

**Module with Submodule** (depth 3):
```
modules/
└── <category>/
    └── <module_name>/
        └── <submodule>/
            └── diagnostics.tf → source = "../../../diagnostics"
```

**Verification Command**:
```bash
# From module directory
cd modules/<category>/<module_name>/
realpath ../../diagnostics
# Should output: /path/to/repo/modules/diagnostics
```

---

### Step 5: Update Module Documentation

Add diagnostics information to the module's README.md (if it exists).

**Section to Add**:

```markdown
## Diagnostics

This module supports Azure Monitor diagnostic settings for comprehensive logging and monitoring.

### Supported Destinations

- Log Analytics Workspace
- Storage Account
- Event Hub

### Example Configuration

See examples directory for complete diagnostic configurations.
```

---

### Step 6: Create Example with Diagnostics

**Location**: `examples/<category>/<service>/200-<service>-diagnostics/configuration.tfvars`

**Standard Example Template**:

```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  rg_service = {
    name = "service-test-1"
  }
  rg_monitoring = {
    name = "monitoring-test-1"
  }
}

# Log Analytics for diagnostics
log_analytics_workspaces = {
  law1 = {
    name = "logs-test-1"
    resource_group = {
      key = "rg_monitoring"
    }
    sku = "PerGB2018"
    retention_in_days = 30
  }
}

# Storage Account for diagnostics (optional)
storage_accounts = {
  diag_storage = {
    name = "diaglogs"
    resource_group = {
      key = "rg_monitoring"
    }
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

# Main service with diagnostics
<category> = {
  <service_name> = {
    service1 = {
      name = "service-instance-1"
      resource_group = {
        key = "rg_service"
      }
      
      # Service-specific configuration
      # ... (service settings)
      
      # Diagnostics configuration
      diagnostic_profiles = {
        operations = {
          name = "operations_logs"
          
          # Logs configuration
          log = [
            {
              category = "Administrative"
              enabled  = true
              retention_policy = {
                enabled = true
                days    = 90
              }
            },
            {
              category = "Security"
              enabled  = true
              retention_policy = {
                enabled = true
                days    = 365
              }
            }
          ]
          
          # Metrics configuration
          metric = [
            {
              category = "AllMetrics"
              enabled  = true
              retention_policy = {
                enabled = true
                days    = 30
              }
            }
          ]
          
          # Destinations
          log_analytics_destination_type = "Dedicated"
        }
      }
    }
  }
}

# Diagnostics object (passed to module)
diagnostics = {
  operations = {
    log_analytics = {
      log_analytics_workspace = {
        key = "law1"
      }
    }
    storage_account = {
      storage_account = {
        key = "diag_storage"
      }
    }
  }
}
```

**Key Components**:

1. **Log Analytics Workspace** - Primary destination
2. **Storage Account** - Optional long-term storage
3. **Diagnostic Profiles** - Define what to log
4. **Diagnostics Object** - Maps profiles to destinations

---

### Step 7: Common Log Categories by Service

Different Azure services support different log categories. Here are common patterns:

**Storage Account**:
```hcl
log = [
  { category = "StorageRead" },
  { category = "StorageWrite" },
  { category = "StorageDelete" }
]
```

**Key Vault**:
```hcl
log = [
  { category = "AuditEvent" },
  { category = "AzurePolicyEvaluationDetails" }
]
```

**AKS Cluster**:
```hcl
log = [
  { category = "kube-apiserver" },
  { category = "kube-controller-manager" },
  { category = "kube-scheduler" },
  { category = "kube-audit" },
  { category = "cluster-autoscaler" }
]
```

**App Service**:
```hcl
log = [
  { category = "AppServiceHTTPLogs" },
  { category = "AppServiceConsoleLogs" },
  { category = "AppServiceAppLogs" },
  { category = "AppServiceAuditLogs" }
]
```

**SQL Database**:
```hcl
log = [
  { category = "SQLInsights" },
  { category = "AutomaticTuning" },
  { category = "QueryStoreRuntimeStatistics" },
  { category = "Errors" },
  { category = "DatabaseWaitStatistics" }
]
```

**Consult Azure documentation** for complete list per service.

---

### Step 8: Test Diagnostics with Mock Tests

**Note**: Mock tests use the same configuration file as deployment examples. No separate mock files needed.

---

### Step 9: Test Diagnostics Integration

**Mock Test**:
```bash
cd examples
terraform test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/200-<service>-diagnostics/configuration.tfvars \
  -verbose
```

**Alternative (single command)**:
```bash
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/200-<service>-diagnostics/configuration.tfvars \
  -verbose
```

**Real Deployment Test** (optional):
```bash
# Verify Azure subscription first
az account show --query "{subscriptionId:id, name:name}" -o table
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

cd examples
terraform_with_var_files \
  --dir /<category>/<service>/200-<service>-diagnostics/ \
  --action plan \
  --auto auto \
  --workspace test
```

---

### Step 10: Add to CI/CD (Optional)

If creating a comprehensive diagnostics example, add to workflow:

**Location**: `.github/workflows/standalone-scenarios*.json`

```json
{
  "config_files": [
    "existing/examples",
    "<category>/<service>/200-<service>-diagnostics",
    "more/examples"
  ]
}
```

---

## Diagnostics Module Structure

The shared diagnostics module (`modules/diagnostics/`) handles all diagnostic settings uniformly.

**What it does**:
- Creates `azurerm_monitor_diagnostic_setting` resource
- Resolves Log Analytics workspace by key or ID
- Resolves Storage Account by key or ID
- Resolves Event Hub by key or ID
- Applies diagnostic profiles
- Manages log categories and metrics

**You don't need to modify** the diagnostics module itself - just use it.

---

## Integration Checklist

- [ ] Service supports diagnostic settings (verified in Azure docs)
- [ ] Created `diagnostics.tf` in module directory
- [ ] Added `diagnostics` variable to `variables.tf`
- [ ] Verified relative path to diagnostics module (`../../diagnostics`)
- [ ] Created deployment example (200-level) with diagnostics
- [ ] Tested mock test passes
- [ ] Updated module README with diagnostics info (optional)
- [ ] Added to CI/CD workflow (optional)

---

## Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Module not found" | Wrong relative path | Verify path with `realpath ../../diagnostics` |
| "Unknown variable: diagnostics" | Variable not added | Add variable to `variables.tf` |
| "Invalid log category" | Service doesn't support category | Check Azure docs for supported categories |
| "Diagnostics not created" | Count condition not met | Ensure `diagnostics` object is passed in example |
| "Workspace not found" | Wrong key reference | Verify key matches in `log_analytics_workspaces` |

---

## Diagnostics Best Practices

### 1. Retention Policies

```hcl
# Security logs - long retention
retention_policy = {
  enabled = true
  days    = 365
}

# Operational logs - medium retention
retention_policy = {
  enabled = true
  days    = 90
}

# Debug logs - short retention
retention_policy = {
  enabled = true
  days    = 30
}
```

### 2. Essential Categories

Always enable these if available:
- Administrative operations
- Security events
- Audit logs
- AllMetrics (for performance monitoring)

### 3. Multiple Destinations

```hcl
diagnostics = {
  operations = {
    # Hot path - Log Analytics for queries
    log_analytics = {
      log_analytics_workspace = { key = "law1" }
    }
    # Cold path - Storage for long-term retention
    storage_account = {
      storage_account = { key = "archive_storage" }
    }
    # Event-driven - Event Hub for SIEM integration
    event_hub = {
      event_hub_namespace = { key = "eventhub1" }
      event_hub_name = "security-events"
    }
  }
}
```

### 4. Dedicated Log Analytics Tables

```hcl
log_analytics_destination_type = "Dedicated"  # Creates resource-specific tables
# vs
log_analytics_destination_type = "AzureDiagnostics"  # Uses shared table (default)
```

**Use Dedicated for**:
- Better query performance
- Separate retention policies
- Easier data management

---

## Example Services with Diagnostics

Reference these existing implementations:

```bash
# Find modules with diagnostics already implemented
find modules -name "diagnostics.tf" -type f

# Example outputs:
# modules/storage/storage_account/diagnostics.tf
# modules/keyvault/keyvault/diagnostics.tf
# modules/databases/mssql_database/diagnostics.tf
# modules/networking/application_gateway/diagnostics.tf
```

**Study existing patterns**:
```bash
cat modules/storage/storage_account/diagnostics.tf
cat examples/storage/storage_account/200-storage-account-diagnostics/configuration.tfvars
```

---

## Quick Reference: Standard Diagnostics Block

**In diagnostics.tf**:
```hcl
module "diagnostics" {
  source            = "../../diagnostics"
  count             = var.diagnostics != null ? 1 : 0
  resource_id       = <resource>.id
  resource_location = local.location
  diagnostics       = var.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

**In variables.tf**:
```hcl
variable "diagnostics" {
  description = "Diagnostic settings for the resource."
  default     = null
}
```

**In examples**:
```hcl
diagnostics = {
  profile_name = {
    log_analytics = {
      log_analytics_workspace = { key = "law1" }
    }
  }
}
```

---

## Related Skills

- **module-creation** - Create module with diagnostics from start
- **mock-testing** - Test diagnostics integration
- **example-creation** - Create comprehensive examples

---

## Summary

Adding diagnostics to a module:
1. ✅ Create `diagnostics.tf` with standard module call
2. ✅ Add `diagnostics` variable
3. ✅ Verify relative path
4. ✅ Create examples with diagnostics configuration
5. ✅ Test with mock tests
6. ✅ Document in README

This enables comprehensive Azure Monitor integration for logging, metrics, and compliance.
