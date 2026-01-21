---
name: mock-testing
description: Execute and debug Terraform mock tests for Azure CAF modules. Use this skill when user asks to test a module, run tests, or debug test failures.
---

# Mock Testing for Azure CAF Modules

Mock tests validate that your Terraform module can successfully generate a plan without requiring actual Azure resources.

## Why Mock Testing is MANDATORY

Mock tests ensure:
- ✅ All variable references are correct
- ✅ Resource syntax is valid
- ✅ Dependencies are properly resolved
- ✅ No circular dependencies exist
- ✅ Examples work correctly
- ✅ No breaking changes introduced

## Directory Structure: Deployment vs Mock Examples

**CRITICAL**: Mock test examples are stored separately from deployment examples:

```
examples/
├── <category>/
│   └── <service>/
│       └── 100-simple-service/          # Deployment example
│           ├── configuration.tfvars     # Uses key-based references
│           └── README.md
└── tests/
    ├── mock/
    │   └── e2e_plan.tftest.hcl          # Test framework
    └── <category>/
        └── <service>/
            └── 100-simple-service-mock/  # Mock test example
                ├── configuration.tfvars  # Uses direct IDs
                └── README.md
```

### When to Create Each Type

**Deployment Example** (`examples/<category>/<service>/`):
- Production-ready configuration patterns
- Key-based resource references
- Shows how to use the module in real deployments
- Example: `resource_group = { key = "rg1" }`

**Mock Test Example** (`examples/tests/<category>/<service>/`):
- Validates module syntax and planning
- Direct resource IDs (no remote_objects dependencies)
- Tests module without actual Azure resources
- Example: `resource_group_id = "/subscriptions/.../resourceGroups/rg-test"`

### Why This Separation?

**Terraform Limitation**: Mock tests cannot populate `remote_objects` from resources defined in the same test plan. This is a framework constraint, not a bug.

**Solution**: 
- Deployment examples use key-based refs (rely on remote_objects)
- Mock examples use direct IDs (no remote_objects needed)
- Both serve different but important purposes

## When to Run Mock Tests

**MANDATORY scenarios:**

1. **After creating a new module** - Before marking work complete
2. **After updating a module** - To catch regressions
3. **Before committing changes** - To validate all changes work together
4. **After fixing variable references** - To confirm corrections

### ⚠️ CRITICAL: What NOT to Do

**NEVER use mock test examples for terraform plan/apply on real Azure:**

```bash
# ❌ WRONG - Mock examples only for testing, not for real deployment
cd examples/tests/chaos_studio/100-simple-chaos-target-mock/
terraform plan  # DON'T DO THIS
terraform apply # DON'T DO THIS

# ✅ CORRECT - Use deployment examples for real Azure
cd examples/chaos_studio/100-simple-chaos-target/
terraform plan  # Use this path
terraform apply # Use this path
```

Mock examples contain fake Azure resource IDs that don't exist in your subscription.

## How to Execute Mock Tests

### ⚠️ CRITICAL: Azure Subscription Verification (for real deployments only)

**Mock tests do NOT require Azure subscription** (they use mock providers).

**For REAL deployments (terraform plan/apply), ALWAYS verify subscription first:**

```bash
# 1. Check current Azure subscription
az account show --query "{subscriptionId:id, name:name, state:state}" -o table

# 2. Confirm with user this is correct
# MUST get explicit confirmation before plan/apply

# 3. Export for Terraform
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

### Basic Test Execution

```bash
# Navigate to examples directory
cd /path/to/terraform-azurerm-caf/examples

# Initialize Terraform (required first time or after module changes)
terraform init -upgrade

# Run mock test for a specific example (NO subscription needed)
terraform test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/<example_number>/configuration.tfvars \
  -verbose
```

### Example Commands

```bash
# Test chaos_studio module
cd examples
terraform init -upgrade
terraform test \
  -test-directory=./tests/mock \
  -var-file=./tests/chaos_studio/100-simple-chaos-target-mock/configuration.tfvars \
  -verbose

# Note: Use mock examples from tests/ directory, not deployment examples
# Mock examples have direct IDs, deployment examples have key-based references

# If testing deployment example (for actual deployment planning):
terraform test \
  -test-directory=./tests/mock \
  -var-file=./chaos_studio/100-simple-chaos-target/configuration.tfvars \
  -verbose

# Note: Deployment examples may fail in mock tests if they depend on
# remote_objects that aren't populated during mock testing
```

## Expected Output

### ✅ Success

```
tests/mock/e2e_plan.tftest.hcl... in progress
  run "test_plan"... pass
tests/mock/e2e_plan.tftest.hcl... tearing down
tests/mock/e2e_plan.tftest.hcl... pass

Success! 1 passed, 0 failed.
```

### ❌ Failure

```
tests/mock/e2e_plan.tftest.hcl... in progress
  run "test_plan"... fail
╷
│ Error: Reference to undeclared input variable
│
│   on ../modules/category/service/variables.tf line 10:
│   10:   name = var.wrong_variable_name
│
│ An input variable with the name "wrong_variable_name" has not been declared.
╵
```

## Common Mock Test Errors and Solutions

### Error 1: Reference to Undeclared Input Variable

**Error message:**
```
Error: Reference to undeclared input variable
An input variable with the name "managed_redis" has not been declared.
```

**Cause:** Using resource-specific variable names instead of generic `var.settings`

**Solution:** Update all variable references to use `var.settings`

**Example fix:**
```hcl
# ❌ WRONG
name = var.managed_redis.name

# ✅ CORRECT
name = var.settings.name
```

**Files to check:**
- `modules/<category>/<module>/<module>.tf` - Main resource file
- `modules/<category>/<module>/locals.tf` - Local variable definitions
- `modules/<category>/<module>/diagnostics.tf` - Diagnostics configuration

### Error 2: Reference to Undeclared Local Value

**Error message:**
```
Error: Reference to undeclared local value
A local value with the name "tags" has not been declared.
```

**Cause:** Missing or incorrect local variable definitions

**Solution:** Ensure standard locals pattern is implemented in `locals.tf`:

```hcl
locals {
  module_tag = {
    "category/module_name" = basename(abspath(path.module))
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
}
```

### Error 3: Invalid Reference in Dynamic Block

**Error message:**
```
Error: Invalid reference
A reference to a resource type must be followed by at least one attribute access
```

**Cause:** Using reserved keywords (e.g., `module`) as iterator names in dynamic blocks

**Solution:** Rename iterator to avoid reserved keywords

**Example fix:**
```hcl
# ❌ WRONG - 'module' is a reserved keyword
dynamic "origins" {
  for_each = try(var.settings.origins, {})
  iterator = module
  
  content {
    name = module.value.name
  }
}

# ✅ CORRECT - Use descriptive name
dynamic "origins" {
  for_each = try(var.settings.origins, {})
  iterator = origin
  
  content {
    name = origin.value.name
  }
}
```

### Error 4: Module Not Installed

**Error message:**
```
Error: Module not installed
This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
```

**Cause:** Terraform not initialized or module changes not recognized

**Solution:**
```bash
cd examples
terraform init -upgrade
```

**When to run:**
- First time testing
- After creating new module
- After modifying module source paths
- After changing required_providers

### Error 5: Invalid for_each Argument

**Error message:**
```
Error: Invalid for_each argument
The given "for_each" argument value is unsuitable
```

**Cause:** for_each receiving null or non-map/set value

**Solution:** Ensure proper default values with try()

**Example fix:**
```hcl
# ❌ WRONG - Can receive null
for_each = var.settings.optional_blocks

# ✅ CORRECT - Defaults to empty map
for_each = try(var.settings.optional_blocks, {})
```

### Error 6: Cycle Error (Circular Dependency)

**Error message:**
```
Error: Cycle: module.resource1, module.resource2
```

**Cause:** Circular dependency between modules

**Solution:**
1. Review dependency chain
2. Use explicit `depends_on` if needed
3. Restructure resource references
4. Check for mutual dependencies in remote_objects

**Example fix:**
```hcl
# Add explicit dependency order
resource "azurerm_resource_a" "example" {
  # ...
  
  depends_on = [azurerm_resource_b.example]
}
```

## Debugging Failed Tests

### Step-by-Step Debugging Process

1. **Read the full error message**
   - Note the file and line number
   - Identify the variable or resource causing the issue

2. **Check the module file**
   ```bash
   # Open the file mentioned in error
   code modules/<category>/<module>/<file>.tf
   ```

3. **Verify variable names**
   - All references should use `var.settings.*`
   - NOT `var.managed_redis.*` or other resource-specific names

4. **Check locals.tf exists and is complete**
   - Must have: module_tag, tags, location, resource_group_name

5. **Validate example configuration**
   ```bash
   # Open the example tfvars
   code examples/<category>/<module>/100-*/configuration.tfvars
   ```

6. **Check variable definitions**
   ```bash
   # Verify variable is defined in module
   code modules/<category>/<module>/variables.tf
   ```

7. **Re-run test after fix**
   ```bash
   cd examples
   terraform test -test-directory=./tests/mock -var-file=./<path>/configuration.tfvars -verbose
   ```

## Mock Test Workflow

```
┌─────────────────────────────────────┐
│  1. Make Changes to Module          │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  2. Navigate to examples/           │
│     cd examples                     │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  3. Initialize Terraform            │
│     terraform init -upgrade         │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  4. Run Mock Test                   │
│     terraform test ...              │
└─────────────────┬───────────────────┘
                  │
          ┌───────┴───────┐
          │               │
          ▼               ▼
    ┌─────────┐     ┌─────────┐
    │  PASS   │     │  FAIL   │
    └────┬────┘     └────┬────┘
         │               │
         │               ▼
         │     ┌──────────────────┐
         │     │  5. Debug Error  │
         │     │  - Read message  │
         │     │  - Check file    │
         │     │  - Fix issue     │
         │     └────┬─────────────┘
         │          │
         │          ▼
         │     ┌──────────────────┐
         │     │  6. Re-test      │
         │     └────┬─────────────┘
         │          │
         └──────────┴──────────────┐
                                   │
                                   ▼
                          ┌─────────────────┐
                          │  7. Commit      │
                          └─────────────────┘
```

## Testing Multiple Examples

If a module has multiple examples, test each one:

```bash
cd examples

# Test all examples for a module
for config in ./<category>/<module>/*/configuration.tfvars; do
  echo "Testing: $config"
  terraform test -test-directory=./tests/mock -var-file="$config" -verbose
  if [ $? -ne 0 ]; then
    echo "FAILED: $config"
    break
  fi
done
```

## Integration with CI/CD

Mock tests are also run in GitHub Actions workflows. Ensure your example is added to the appropriate workflow file:

- `.github/workflows/standalone-scenarios.json`
- `.github/workflows/standalone-scenarios-additional.json`
- `.github/workflows/standalone-compute.json`
- `.github/workflows/standalone-networking.json`
- `.github/workflows/standalone-dataplat.json`

## Best Practices

1. **Always test before committing** - Catches issues early
2. **Test after every change** - Even small changes can break things
3. **Fix root causes** - Don't comment out failing code
4. **Keep tests passing** - Never commit code that breaks tests
5. **Test all examples** - If module has multiple examples, test each one
6. **Document test commands** - In module README.md for other developers

## Quick Reference Commands

```bash
# Initialize
cd examples && terraform init -upgrade

# Test single example
terraform test -test-directory=./tests/mock -var-file=./path/to/configuration.tfvars -verbose

# Test with detailed output
TF_LOG=DEBUG terraform test -test-directory=./tests/mock -var-file=./path/to/configuration.tfvars -verbose

# Clean state between tests
rm -rf .terraform/ .terraform.lock.hcl
terraform init -upgrade
```

## Checklist

Before marking testing complete:

- [ ] Navigated to `examples/` directory
- [ ] Ran `terraform init -upgrade`
- [ ] Executed mock test for each example
- [ ] All tests pass successfully
- [ ] Fixed any errors found
- [ ] Verified no regression in existing examples
- [ ] Ready to commit changes

## When Mock Tests Fail

**DO:**
- ✅ Read the full error message carefully
- ✅ Check the exact file and line number
- ✅ Verify variable naming (use `var.settings`)
- ✅ Ensure standard locals are complete
- ✅ Fix the root cause in the module
- ✅ Re-test after each fix

**DON'T:**
- ❌ Ignore test failures
- ❌ Comment out failing code
- ❌ Skip testing "small changes"
- ❌ Commit broken tests
- ❌ Assume tests will pass in CI if they fail locally
