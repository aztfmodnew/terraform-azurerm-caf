# Root Module Integration Skill

Complete workflow for integrating a new Terraform module into the Azure CAF root framework.

## When to Use This Skill

Use this skill **after** creating a new module when you need to:
- Wire the module into the root aggregator
- Set up combined_objects for cross-module references
- Create deployment and mock test examples
- Integrate with CI/CD pipelines

## Quick Start

Ask Copilot:
- "Integrate the managed_redis module into root"
- "Wire up the new chaos_studio_target module"
- "Connect grafana module to framework"
- "Set up combined objects for container_app"

## What This Skill Covers

This skill guides you through the complete 8-step integration process:

1. **Create Root Aggregator** - `/category_module_names.tf`
2. **Add Variable** - `/variables.tf`
3. **Configure Locals** - `/locals.tf`
4. **Set Up Combined Objects** - `/locals.combined_objects.tf`
5. **Create Deployment Example** - `/examples/category/service/100-*/`
6. **Create Mock Test Example** - `/examples/tests/category/service/100-*-mock/`
7. **Add to CI/CD** - `.github/workflows/standalone-*.json`
8. **Test Integration** - Mock tests and validation

## Example Usage

### Scenario: Integrating Azure Managed Redis

**User Request:**
```
I've created the managed_redis module in modules/cache/managed_redis/. 
Now I need to integrate it into the root framework.
```

**Copilot Response (using this skill):**

1. Creates `/cache_managed_redis.tf` with module call
2. Adds `variable "cache"` to `/variables.tf`
3. Adds `managed_redis = try(var.cache.managed_redis, {})` to `/locals.tf`
4. Creates `combined_objects_managed_redis` in `/locals.combined_objects.tf`
5. Creates deployment example at `/examples/cache/managed_redis/100-simple-managed-redis/`
6. Creates mock example at `/examples/tests/cache/managed_redis/100-simple-managed-redis-mock/`
7. Adds path to `.github/workflows/standalone-scenarios.json`
8. Provides test commands for validation

## Key Features

### Automatic Dependency Detection

The skill analyzes your module to determine what dependencies need to be passed via `remote_objects`:

```hcl
remote_objects = {
  resource_groups     = local.combined_objects_resource_groups
  vnets              = local.combined_objects_vnets
  virtual_subnets    = local.combined_objects_virtual_subnets
  managed_identities = local.combined_objects_managed_identities
}
```

### Example Generation

Creates both types of examples:

**Deployment Example** (key-based references):
```hcl
cache = {
  managed_redis = {
    redis1 = {
      resource_group = {
        key = "test_rg"  # Key-based reference
      }
    }
  }
}
```

**Mock Test Example** (direct IDs):
```hcl
cache = {
  managed_redis = {
    redis1 = {
      resource_group_id = "/subscriptions/.../resourceGroups/rg-test"  # Direct ID
    }
  }
}
```

### Integration Validation

Provides commands to verify each step:

```bash
# Check module source path
ls modules/cache/managed_redis/*.tf

# Verify variable exists
grep "variable \"cache\"" variables.tf

# Test integration
cd examples
terraform test -test-directory=./tests/mock -var-file=...
```

**Alternative**: `terraform -chdir=examples test -test-directory=./tests/mock -var-file=...`

## Checklist Provided

The skill provides a comprehensive checklist to track progress:

- [ ] Root aggregator file created
- [ ] Variable added
- [ ] Locals configured
- [ ] Combined objects set up
- [ ] Deployment example created
- [ ] Mock example created
- [ ] CI/CD integrated
- [ ] Tests passing

## Common Issues Handled

The skill includes solutions for common integration problems:

| Issue | What Copilot Does |
|-------|-------------------|
| Wrong module source path | Validates path exists before creating aggregator |
| Missing remote_objects | Analyzes module dependencies and adds all needed |
| Incorrect example structure | Uses templates with correct key-based references |
| CI workflow syntax errors | Validates JSON and correct path format |
| Mock test failures | Provides debugging commands and common solutions |

## Integration Patterns

### Simple Module (Single Resource)
```
modules/cache/managed_redis/ → cache_managed_redis.tf
```

### Complex Module (Multiple Resources)
```
modules/chaos_studio/
  ├── chaos_studio_target/
  ├── chaos_studio_capability/
  └── chaos_studio_experiment/

→ Creates 3 separate aggregator files:
  - chaos_studio_chaos_studio_targets.tf
  - chaos_studio_chaos_studio_capabilities.tf
  - chaos_studio_chaos_studio_experiments.tf
```

### Module with Submodules
```
modules/cognitive_services/cognitive_account/
  └── customer_managed_key/

→ Single aggregator: cognitive_services_cognitive_accounts.tf
   (submodule called internally by parent module)
```

## Testing Strategy

The skill ensures proper testing by:

1. **Creating mock example** for syntax validation
2. **Providing test commands** for execution
3. **Validating combined_objects** references
4. **Checking CI integration** with workflow files

## Prerequisites

Before using this skill, ensure:
- ✅ Module is created and tested
- ✅ Module follows CAF standards
- ✅ Mock tests pass for the module
- ✅ You know the category (cache, compute, networking, etc.)

## Related Skills

Use these skills in conjunction:
- **module-creation** - Create module before integration
- **mock-testing** - Test after integration
- **azure-schema-validation** - Validate during module creation

## Files Modified

This skill modifies/creates files in these locations:
- `/` - Root aggregator file
- `/variables.tf` - Variable definition
- `/locals.tf` - Locals extraction
- `/locals.combined_objects.tf` - Combined objects
- `/examples/<category>/<service>/` - Deployment examples

- `.github/workflows/standalone-*.json` - CI configuration

## Success Criteria

Integration is complete when:
✅ Mock tests pass
✅ Module appears in combined_objects
✅ Examples are created and working
✅ CI workflow includes the example
✅ No errors in terraform plan

## Tips

- **Work systematically** - Follow all 8 steps in order
- **Test incrementally** - Run mock tests after each major change
- **Verify paths** - Double-check all file locations
- **Keep consistent** - Match patterns from similar modules
- **Ask questions** - Clarify before making changes

## Need Help?

If Copilot doesn't automatically use this skill:
- Explicitly mention "integrate into root" or "wire up module"
- Reference "8-step integration" or "combined objects"
- Ask about specific steps (e.g., "create root aggregator")
