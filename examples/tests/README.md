# Mock Test Examples

This directory contains mock test examples for validating Terraform modules without requiring actual Azure resources.

## Purpose

Mock test examples serve a different purpose than deployment examples:

- **Validate module syntax** and Terraform planning
- **Test without Azure resources** (no authentication required)
- **Catch breaking changes** early in development
- **Ensure variable references** are correct
- **Verify resource structure** before deployment

## Directory Structure

```
examples/
├── <category>/
│   └── <service>/
│       └── 100-simple-service/          # Deployment example
│           ├── configuration.tfvars     # Key-based references
│           └── README.md
└── tests/
    ├── mock/
    │   └── e2e_plan.tftest.hcl          # Test framework
    └── <category>/
        └── <service>/
            └── 100-simple-service-mock/  # Mock test example
                ├── configuration.tfvars  # Direct IDs
                └── README.md
```

## Key Differences: Deployment vs Mock Test Examples

| Aspect | Deployment Examples | Mock Test Examples |
|--------|--------------------|--------------------|
| **Location** | `examples/<category>/<service>/` | `examples/tests/<category>/<service>/` |
| **Purpose** | Production deployment patterns | Syntax validation |
| **References** | Key-based (`resource_group = { key = "rg1" }`) | Direct IDs (`resource_group_id = "/subscriptions/..."`) |
| **Dependencies** | Rely on `remote_objects` resolution | NO `remote_objects` dependencies |
| **Naming** | No suffix (e.g., `100-simple-service`) | `-mock` suffix (e.g., `100-simple-service-mock`) |

## Why Separate Examples?

**Terraform Limitation**: Mock tests cannot populate `remote_objects` from resources defined in the same plan. This is a framework constraint.

**Solution**:
- **Deployment examples** use key-based references that rely on `remote_objects` for dynamic resolution
- **Mock test examples** use direct resource IDs to bypass this limitation

Both types serve important but different purposes:
- Deployment examples show **production patterns**
- Mock test examples enable **automated validation**

## Running Tests

To run tests in Terraform, you can use the following command from the repository root:

```bash
# Navigate to examples directory
cd examples

# Initialize Terraform (first time or after module changes)
terraform init -upgrade

# Run mock test for a specific module
terraform test \
  -test-directory=./tests/mock \
  -var-file=./tests/<category>/<service>/100-example-mock/configuration.tfvars \
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

# Test communication_services module (older example, may need migration to tests/)
terraform test \
  -test-directory=./tests/mock \
  -var-file=./communication/communication_services/101-communication_service/configuration.tfvars \
  -verbose

# Test multiple modules
for config in ./tests/*/*/100-*-mock/configuration.tfvars; do
  echo "Testing: $config"
  terraform test -test-directory=./tests/mock -var-file="$config" -verbose
  if [ $? -ne 0 ]; then
    echo "FAILED: $config"
    break
  fi
done
```

### Expected Output
```bash
tests/mock/e2e_plan.tftest.hcl... in progress
  run "test_plan"... pass

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.example.random_string.prefix[0] will be created
  + resource "random_string" "prefix" {
      + id          = (known after apply)
      + length      = 4
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = false
      + numeric     = false
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

  # module.example.module.communication_services["cs1"].azurecaf_name.acs will be created
  + resource "azurecaf_name" "acs" {
      + clean_input   = true
      + id            = (known after apply)
      + name          = "test-acs1-re1"
      + passthrough   = false
      + prefixes      = (known after apply)
      + random_length = 0
      + resource_type = "azurerm_communication_service"
      + result        = (known after apply)
      + results       = (known after apply)
      + separator     = "-"
      + use_slug      = true
    }

  # module.example.module.communication_services["cs1"].azurerm_communication_service.acs will be created
  + resource "azurerm_communication_service" "acs" {
      + data_location               = "United States"
      + id                          = (known after apply)
      + name                        = (known after apply)
      + primary_connection_string   = (known after apply)
      + primary_key                 = (known after apply)
      + resource_group_name         = (known after apply)
      + secondary_connection_string = (known after apply)
      + secondary_key               = (known after apply)
      + tags                        = {
          + "module" = "communication_services"
        }
    }

  # module.example.module.communication_services["cs2"].azurecaf_name.acs will be created
  + resource "azurecaf_name" "acs" {
      + clean_input   = true
      + id            = (known after apply)
      + name          = "test-acs2-re2"
      + passthrough   = false
      + prefixes      = (known after apply)
      + random_length = 0
      + resource_type = "azurerm_communication_service"
      + result        = (known after apply)
      + results       = (known after apply)
      + separator     = "-"
      + use_slug      = true
    }

  # module.example.module.communication_services["cs2"].azurerm_communication_service.acs will be created
  + resource "azurerm_communication_service" "acs" {
      + data_location               = "United States"
      + id                          = (known after apply)
      + name                        = (known after apply)
      + primary_connection_string   = (known after apply)
      + primary_key                 = (known after apply)
      + resource_group_name         = (known after apply)
      + secondary_connection_string = (known after apply)
      + secondary_key               = (known after apply)
      + tags                        = {
          + "module" = "communication_services"
        }
    }

  # module.example.module.resource_groups["rg1"].azurecaf_name.rg will be created
  +

## Creating Mock Test Examples

When creating a new module, you MUST create both types of examples:

### 1. Create Deployment Example

Location: `examples/<category>/<service>/100-simple-service/`

**Use key-based references**:
```hcl
chaos_studio = {
  chaos_studio_targets = {
    storage_target = {
      target_resource = {
        key = "test_storage"  # Key-based reference
      }
    }
  }
}
```

### 2. Create Mock Test Example

Location: `examples/tests/<category>/<service>/100-simple-service-mock/`

**Use direct IDs**:
```hcl
chaos_studio = {
  chaos_studio_targets = {
    storage_target = {
      # Direct ID - no remote_objects needed
      target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/chaostestst01"
    }
  }
}
```

### Key Points

- Mock example directory name should have `-mock` suffix
- Use realistic but fake UUIDs/IDs (e.g., all zeros subscription ID)
- Match the structure of deployment example
- Keep configuration minimal (focus on required attributes)
- Document in README.md that this is for testing only

## Common Mock Test Patterns

### Pattern 1: Direct Resource IDs

```hcl
# Instead of key-based reference
resource_group = {
  key = "rg1"
}

# Use direct ID in mock
resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-00001"
```

### Pattern 2: Direct Subnet IDs

```hcl
# Instead of key-based reference
subnet = {
  vnet_key   = "vnet1"
  subnet_key = "subnet1"
}

# Use direct ID in mock
subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-00001/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
```

### Pattern 3: Direct Parent Resource IDs

```hcl
# Instead of key-based reference
chaos_studio_target = {
  key = "target1"
}

# Use direct ID in mock
chaos_studio_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/st01/providers/Microsoft.Chaos/targets/Microsoft-StorageAccount"
```

## When Mock Tests Fail

Common issues and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| "Reference to undeclared input variable" | Using resource-specific var names | Use `var.settings.*` pattern |
| "Reference to undeclared local value" | Missing standard locals | Add to `locals.tf` |
| "Invalid reference" | Reserved keyword as iterator | Rename iterator |
| "Module not installed" | Terraform not initialized | Run `terraform init -upgrade` |
| "Call to function coalesce failed" | All arguments return null | Use direct IDs in mock example |

## Best Practices

1. **Create both types** - Always create deployment AND mock test examples
2. **Match structure** - Mock examples should mirror deployment examples
3. **Use realistic IDs** - Use proper Azure resource ID format
4. **Test before commit** - All mock tests must pass
5. **Document purpose** - Each example should have a clear README
6. **Keep minimal** - Focus on essential configuration only

## CI/CD Integration

**Note**: Only deployment examples are registered in CI workflow JSON files. Mock test examples are run separately during development and PR validation.

Deployment examples are added to:
- `.github/workflows/standalone-scenarios.json`
- `.github/workflows/standalone-compute.json`
- `.github/workflows/standalone-networking.json`
- `.github/workflows/standalone-dataplat.json`

Mock tests are run automatically as part of the test validation pipeline.

## Additional Resources

- [Mock Testing Skill](/.github/skills/mock-testing/SKILL.md)
- [Module Creation Guide](/.github/skills/module-creation/SKILL.md)
- [Example Instructions](/.github/instructions/examples.instructions.md)
- [Terraform Test Framework](https://developer.hashicorp.com/terraform/language/tests) resource "azurecaf_name" "rg" {
      + clean_input   = true
      + id            = (known after apply)
      + name          = "rg1"
      + passthrough   = false
      + prefixes      = (known after apply)
      + random_length = 0
      + resource_type = "azurerm_resource_group"
      + result        = (known after apply)
      + results       = (known after apply)
      + separator     = "-"
      + use_slug      = true
    }

  # module.example.module.resource_groups["rg1"].azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "australiacentral"
      + name     = (known after apply)
      + tags     = {
          + "landingzone"   = "examples"
          + "rover_version" = null
        }
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + objects = (sensitive value)

tests/mock/e2e_plan.tftest.hcl... tearing down
tests/mock/e2e_plan.tftest.hcl... pass

Success! 1 passed, 0 failed.

```
