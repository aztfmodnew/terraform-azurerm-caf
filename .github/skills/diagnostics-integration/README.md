# Diagnostics Integration Skill

Add Azure Monitor diagnostic settings to Terraform modules for comprehensive logging and monitoring.

## When to Use This Skill

Use this skill when you need to:
- Add diagnostics to a new module during creation
- Enable monitoring on an existing module
- Implement compliance requirements for logging
- Set up log retention and archival

## Quick Start

Ask Copilot:
- "Add diagnostics to the managed_redis module"
- "Enable monitoring for storage_account module"
- "Integrate Azure Monitor diagnostics"
- "Add diagnostic settings support"

## What This Skill Covers

### Core Implementation
1. Create `diagnostics.tf` file with module integration
2. Add `diagnostics` variable to module
3. Verify relative paths
4. Update module documentation

### Example Creation
5. Create deployment example with Log Analytics
6. Create mock test example
7. Add to CI/CD workflows (optional)

### Testing & Validation
8. Test diagnostics integration
9. Verify log categories
10. Validate retention policies

## Key Features

### Automatic Service Detection

The skill checks if the Azure service supports diagnostic settings before proceeding.

### Standard Integration Pattern

Uses the shared `modules/diagnostics/` module for consistency:

```hcl
module "diagnostics" {
  source            = "../../diagnostics"
  count             = var.diagnostics != null ? 1 : 0
  resource_id       = azurerm_<resource>.id
  resource_location = local.location
  diagnostics       = var.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

### Multi-Destination Support

Supports all Azure diagnostic destinations:
- ✅ Log Analytics Workspace (queries and alerts)
- ✅ Storage Account (long-term archival)
- ✅ Event Hub (SIEM integration)

### Service-Specific Categories

Automatically identifies correct log categories for each service:

| Service | Key Categories |
|---------|----------------|
| Storage Account | StorageRead, StorageWrite, StorageDelete |
| Key Vault | AuditEvent, AzurePolicyEvaluationDetails |
| AKS Cluster | kube-apiserver, kube-audit, cluster-autoscaler |
| App Service | AppServiceHTTPLogs, AppServiceConsoleLogs |
| SQL Database | SQLInsights, AutomaticTuning, Errors |

## Example Usage

### Scenario 1: Adding Diagnostics to New Module

**User Request:**
```
I'm creating a managed_redis module. Add diagnostics support to it.
```

**Copilot Response (using this skill):**

1. Creates `modules/cache/managed_redis/diagnostics.tf`
2. Adds `diagnostics` variable to `variables.tf`
3. Creates example at `examples/cache/managed_redis/200-managed-redis-diagnostics/`
4. Provides test commands

### Scenario 2: Enabling Monitoring on Existing Module

**User Request:**
```
The storage_account module exists but doesn't have diagnostics. Add monitoring support.
```

**Copilot Response:**

1. Checks if `diagnostics.tf` already exists
2. If not, creates it with correct relative path
3. Adds variable if missing
4. Creates comprehensive example with Log Analytics and Storage Account destinations
5. Tests integration

## Complete Example Generated

### Deployment Example

```hcl
# Log Analytics for monitoring
log_analytics_workspaces = {
  law1 = {
    name = "logs-test-1"
    resource_group = { key = "rg_monitoring" }
    sku = "PerGB2018"
    retention_in_days = 30
  }
}

# Service with diagnostics
cache = {
  managed_redis = {
    redis1 = {
      name = "redis-instance-1"
      resource_group = { key = "rg_service" }
      
      # Diagnostics configuration
      diagnostic_profiles = {
        operations = {
          name = "operations_logs"
          log = [
            {
              category = "ConnectedClientList"
              enabled  = true
              retention_policy = {
                enabled = true
                days    = 90
              }
            }
          ]
          metric = [
            {
              category = "AllMetrics"
              enabled  = true
            }
          ]
        }
      }
    }
  }
}

diagnostics = {
  operations = {
    log_analytics = {
      log_analytics_workspace = { key = "law1" }
    }
  }
}
```

## Diagnostics Best Practices Applied

### 1. Retention Policies by Sensitivity

```hcl
# Security logs - 365 days
# Compliance logs - 90 days
# Operational logs - 30 days
# Debug logs - 7 days
```

### 2. Essential Categories Always Enabled

- Administrative operations
- Security events
- AllMetrics (performance)

### 3. Dedicated Log Analytics Tables

```hcl
log_analytics_destination_type = "Dedicated"
```

Benefits: Better query performance, separate retention, easier management.

## Integration Checklist Provided

- [ ] Service supports diagnostics (Azure docs verified)
- [ ] `diagnostics.tf` created
- [ ] `diagnostics` variable added
- [ ] Relative path verified (`../../diagnostics`)
- [ ] Deployment example created (200-level)
- [ ] Mock test example created
- [ ] Tests passing
- [ ] Documentation updated

## Common Issues Handled

| Issue | Solution |
|-------|----------|
| Wrong relative path | Validates with `realpath` command |
| Invalid log category | References Azure docs for service-specific categories |
| Diagnostics not created | Ensures `diagnostics` object passed in examples |
| Missing workspace | Validates key references in examples |

## Services Commonly Requiring Diagnostics

The skill includes patterns for:
- Storage Accounts
- Key Vaults
- SQL Databases
- Redis Cache
- AKS Clusters
- App Services
- Container Apps
- Application Gateways
- Cognitive Services
- Virtual Networks

## Testing Strategy

### Mock Test
```bash
cd examples
terraform test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/200-<service>-diagnostics/configuration.tfvars \
  -verbose
```

**Alternative**: `terraform -chdir=examples test ...`

### Real Deployment
```bash
terraform_with_var_files \
  --dir /<category>/<service>/200-<service>-diagnostics/ \
  --action plan
```

## Files Modified/Created

- `modules/<category>/<module>/diagnostics.tf` - New file
- `modules/<category>/<module>/variables.tf` - Add diagnostics variable
- `examples/<category>/<service>/200-*/configuration.tfvars` - Deployment example
- `.github/workflows/standalone-*.json` - CI integration (optional)

## Quick Reference

### Standard Files Added

1. **diagnostics.tf**
   - Module call to shared diagnostics module
   - Count based on `var.diagnostics != null`
   - Pass resource_id and location

2. **Variable in variables.tf**
   ```hcl
   variable "diagnostics" {
     description = "Diagnostic settings for the resource."
     default     = null
   }
   ```

3. **Example Configuration**
   - Log Analytics workspace
   - Diagnostic profiles
   - Log categories and metrics
   - Retention policies

## Prerequisites

Before using this skill:
- ✅ Module exists and is functional
- ✅ Service supports diagnostic settings (verify in Azure docs)
- ✅ Module is properly structured (providers, variables, outputs)

## Success Criteria

Diagnostics integration is complete when:
- ✅ Mock tests pass
- ✅ Diagnostics module called correctly
- ✅ Examples include diagnostics configuration
- ✅ All required log categories included
- ✅ Retention policies defined

## Related Skills

- **module-creation** - Include diagnostics during module creation
- **mock-testing** - Test diagnostics integration
- **root-module-integration** - Wire diagnostics into root module

## Tips

- **Use existing examples** as templates (find with `find modules -name "diagnostics.tf"`)
- **Verify log categories** in Azure documentation for each service
- **Test incrementally** - add diagnostics.tf, then variable, then test
- **Check relative paths** carefully based on module depth
- **Include compliance categories** (Administrative, Security, Audit)

## Need Help?

If Copilot doesn't automatically use this skill:
- Explicitly mention "diagnostics" or "monitoring"
- Ask to "enable logging" or "add diagnostic settings"
- Reference "Azure Monitor integration"
