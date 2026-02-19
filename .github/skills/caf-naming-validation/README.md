# CAF Naming Validation Skill

Validate and enforce Azure Cloud Adoption Framework naming conventions in Terraform modules and examples.

## When to Use This Skill

Use this skill when you need to:
- Validate naming conventions in new/existing modules
- Debug naming-related errors (too long, invalid characters, duplicates)
- Review examples for correct naming patterns
- Ensure CAF compliance across infrastructure

## Quick Start

Ask Copilot:
- "Validate CAF naming for the managed_redis module"
- "Check if example names follow CAF conventions"
- "Fix naming error: name too long"
- "Why is storage account name invalid?"

## What This Skill Covers

### Module Validation
1. Check `azurecaf_name.tf` exists for named resources
2. Verify correct `resource_type` mapping
3. Ensure resource uses `azurecaf_name.name.result`
4. Validate configuration (clean_input, passthrough, use_slug)

### Example Validation
5. Check names don't include CAF prefixes
6. Verify `global_settings.random_length` configured
7. Validate descriptive, meaningful names
8. Test name generation

### Error Resolution
9. Fix length constraint violations
10. Resolve invalid character issues
11. Handle uniqueness conflicts
12. Correct prefix duplication

## Key Features

### Automatic Prefix/Suffix Handling

The azurecaf provider automatically adds appropriate prefixes and random suffixes:

```
Input:  "my-app"
Output: "rg-my-app-ab12c"  (Resource Group)
Output: "stmyappab12c"     (Storage Account - no hyphens)
Output: "kv-my-app-ab12c"  (Key Vault)
```

### Resource Type Mapping

| Azure Resource | Prefix | Max Length | Special Rules |
|----------------|--------|------------|---------------|
| Resource Group | `rg-` | 90 | Alphanumerics, hyphens |
| Storage Account | `st` | 24 | Lowercase, no hyphens, globally unique |
| Key Vault | `kv-` | 24 | Globally unique |
| Virtual Network | `vnet-` | 64 | Alphanumerics, hyphens |
| AKS Cluster | `aks-` | 63 | Alphanumerics, hyphens |
| Redis Cache | `redis-` | 63 | Alphanumerics, hyphens |

### Length Constraint Enforcement

azurecaf automatically:
- ✅ Truncates names that are too long
- ✅ Respects minimum length requirements
- ✅ Removes invalid characters
- ✅ Ensures globally unique names with random suffix

### Example Pattern Detection

**Detects and fixes common errors**:

```hcl
# ❌ DETECTED: Prefix included
name = "rg-my-app"
# Copilot suggests: Remove "rg-" prefix

# ❌ DETECTED: Storage account has hyphens
name = "my-storage-account"
# Copilot suggests: Use "mystorageaccount" (azurecaf cleans it)

# ❌ DETECTED: Name too long
name = "my-very-long-application-name-for-production"
# Copilot suggests: Shorten to "app-prod"
```

## Example Usage

### Scenario 1: Validating New Module

**User Request:**
```
I created a managed_redis module. Validate the CAF naming.
```

**Copilot Response (using this skill):**

Checks:
1. ✅ `azurecaf_name.tf` exists
2. ✅ Uses `resource_type = "azurerm_redis_cache"`
3. ✅ Resource has `name = azurecaf_name.name.result`
4. ✅ Configuration is correct

Result: "CAF naming is correctly implemented"

### Scenario 2: Fixing Example Names

**User Request:**
```
Example fails with "storage account name contains invalid characters"
```

**Copilot Response:**

1. Analyzes example:
   ```hcl
   name = "my-storage-account"  # Has hyphens
   ```

2. Checks `azurecaf_name.tf`:
   ```hcl
   clean_input = true  # Already configured
   ```

3. Identifies issue: Name has hyphens before azurecaf processes it

4. Provides fix:
   ```hcl
   name = "mystorageaccount"  # Or let clean_input handle it
   ```

5. Explains: "azurecaf removes hyphens automatically with clean_input=true"

### Scenario 3: Resolving Prefix Duplication

**User Request:**
```
Generated name is "rg-rg-myapp-xxxxx". Why is rg- duplicated?
```

**Copilot Response:**

1. Checks example:
   ```hcl
   resource_groups = {
     rg1 = {
       name = "rg-myapp"  # ❌ Includes prefix
     }
   }
   ```

2. Explains: "azurecaf adds 'rg-' prefix automatically"

3. Fixes example:
   ```hcl
   resource_groups = {
     rg1 = {
       name = "myapp"  # ✅ No prefix
     }
   }
   ```

4. Result: `rg-myapp-ab12c` (correct)

## Validation Rules Applied

### Module Rules

1. **Named resources MUST have azurecaf_name.tf**
   - Resource Groups, Storage, Key Vaults, etc.
   - Unnamed resources (role assignments) don't need it

2. **Correct resource_type mapping**
   - Maps Azure resource to azurecaf type
   - Example: `azurerm_redis_cache` → `azurerm_redis_cache`

3. **Resource MUST use generated name**
   ```hcl
   # ✅ CORRECT
   name = azurecaf_name.name.result
   
   # ❌ WRONG
   name = var.settings.name
   ```

4. **Configuration MUST handle constraints**
   ```hcl
   clean_input = true  # For special character removal
   ```

### Example Rules

1. **Names MUST NOT include prefixes**
   ```hcl
   # ❌ WRONG
   name = "rg-myapp"
   
   # ✅ CORRECT
   name = "myapp"
   ```

2. **global_settings MUST configure random_length**
   ```hcl
   global_settings = {
     random_length = 5  # For uniqueness
   }
   ```

3. **Names SHOULD be descriptive**
   ```hcl
   # ❌ BAD
   name = "app1"
   
   # ✅ GOOD
   name = "customer-portal-api"
   ```

4. **Storage names SHOULD avoid hyphens**
   ```hcl
   # Works but requires clean_input
   name = "my-storage"
   
   # Cleaner
   name = "mystorage"
   ```

## Common Errors Fixed

### Error: "Name is too long"

**Diagnosis**:
- Base name + prefix + suffix > max length

**Fix**:
```hcl
# Shorten base name
name = "api"  # Instead of "my-application-programming-interface"
```

### Error: "Name contains invalid characters"

**Diagnosis**:
- Resource type doesn't allow certain characters

**Fix**:
```hcl
# In azurecaf_name.tf (should already be there)
clean_input = true
```

### Error: "Storage account name not available"

**Diagnosis**:
- Globally unique name collision

**Fix**:
```hcl
global_settings = {
  random_length = 8  # Increase for more entropy
}
```

### Error: "Prefix duplicated (rg-rg-*)"

**Diagnosis**:
- Example includes prefix

**Fix**:
```hcl
# Remove prefix from example
name = "myapp"  # Not "rg-myapp"
```

### Error: "Name must be lowercase"

**Diagnosis**:
- Storage account name has uppercase

**Fix**:
```hcl
# azurecaf handles this with clean_input=true
# Or provide lowercase name in example
name = "mystorageaccount"  # Not "MyStorageAccount"
```

## Validation Checklist Provided

### Module Checklist
- [ ] `azurecaf_name.tf` exists (if resource is named)
- [ ] Correct `resource_type` specified
- [ ] Resource uses `azurecaf_name.name.result`
- [ ] `clean_input = true` (for constrained resources)
- [ ] `passthrough` configured correctly
- [ ] `use_slug = true` (standard)

### Example Checklist
- [ ] Names don't include CAF prefixes
- [ ] `global_settings.random_length` set (typically 5)
- [ ] Names are descriptive
- [ ] Storage names avoid hyphens (or rely on clean_input)
- [ ] Length appropriate before prefix/suffix

### Test Checklist
- [ ] Mock tests pass
- [ ] Generated names meet length requirements
- [ ] No invalid characters in output
- [ ] No duplicate names in scope
- [ ] Globally unique resources have sufficient entropy

## Validation Commands

### Check Module Structure
```bash
# Verify azurecaf_name.tf exists
ls modules/<category>/<module>/azurecaf_name.tf

# Check resource uses CAF name
grep "azurecaf_name.name.result" modules/<category>/<module>/*.tf
```

### Check Example Patterns
```bash
# Find examples with prefixes (potential issues)
grep -E "name.*=.*(rg-|st|kv-)" examples/**/*.tfvars

# Verify random_length configured
grep "random_length" examples/**/*.tfvars
```

### Test Name Generation
```bash
# Preview generated names
terraform console <<EOF
resource "azurecaf_name" "test" {
  name          = "my-app"
  resource_type = "azurerm_storage_account"
  random_length = 5
  clean_input   = true
}
output "result" { value = azurecaf_name.test.result }
EOF
```

## Best Practices Applied

### 1. Descriptive Base Names
```hcl
name = "customer-portal-api"  # Not "app1"
```

### 2. Appropriate Random Length
```hcl
# Globally unique (storage, keyvault, acr)
random_length = 5-8

# Scoped (resource groups, vnets)
random_length = 3-5

# Parent-scoped (subnets)
random_length = 0
```

### 3. Consistent Naming Across Resources
```hcl
resource_groups  = { rg1 = { name = "customer-portal" } }
storage_accounts = { st1 = { name = "customerportal" } }  # Consistent
key_vaults       = { kv1 = { name = "customer-portal" } }
```

### 4. Environment Indication
```hcl
# Via name
name = "customer-portal-dev"

# Or via global prefixes
global_settings = {
  prefixes = ["dev"]
}
```

## Special Cases Handled

### Storage Accounts
- No hyphens allowed
- Lowercase only
- Globally unique
- `clean_input = true` handles this

### Key Vaults
- Globally unique
- DNS name format
- 3-24 characters

### Subnets
- Parent VNet provides scope
- Usually no random suffix needed
- `random_length = 0`

### Passthrough Mode
```hcl
# When exact name control needed
global_settings = {
  passthrough = true
}
```

## Files Validated

- `modules/<category>/<module>/azurecaf_name.tf` - Naming config
- `modules/<category>/<module>/*.tf` - Resource name usage
- `examples/**/*.tfvars` - Example naming patterns
- `examples/*/configuration.tfvars` - Global settings

## Prerequisites

Before validation:
- ✅ azurecaf provider configured in module
- ✅ Module follows CAF structure
- ✅ Examples follow standard format

## Success Criteria

Validation passes when:
- ✅ All named resources use azurecaf
- ✅ No prefixes in example names
- ✅ Generated names meet all constraints
- ✅ No naming errors in tests
- ✅ Names are descriptive and consistent

## Related Skills

- **module-creation** - Implement CAF naming from start
- **mock-testing** - Test name generation
- **azure-schema-validation** - Verify naming constraints

## Tips

- **Check existing modules** for naming patterns
- **Use clean_input** for resources with character constraints
- **Test name generation** before deploying
- **Keep names short** to allow for prefix/suffix
- **Use random_length appropriately** based on uniqueness needs
- **Never include prefixes** in example names

## Need Help?

If Copilot doesn't automatically use this skill:
- Explicitly mention "CAF naming" or "naming convention"
- Ask about "naming errors" or "invalid name"
- Reference "azurecaf" or "name generation"
