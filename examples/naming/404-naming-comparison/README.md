# Naming Method Comparison Example

This example demonstrates **all three naming methods** of the hybrid system side by side, allowing you to see the differences and choose the best approach for your needs.

## Naming Methods Demonstrated

### 🔧 Method 1: Local Module (Default)
- **Configuration**: Uses local naming module with organizational patterns
- **Flexibility**: High - full control over component order, separators, etc.
- **Consistency**: High - follows organizational standards
- **Example**: `complocalmoduletest001`

### ⚡ Method 2: azurecaf Provider
- **Configuration**: Uses azurecaf provider for naming
- **Flexibility**: Medium - follows azurecaf conventions
- **Consistency**: High - industry standard patterns
- **Example**: Uses azurecaf provider output

### 🎯 Method 3: Passthrough
- **Configuration**: Uses exact name provided without modifications
- **Flexibility**: Maximum - complete control
- **Consistency**: Variable - depends on user input
- **Example**: `passthroughexample`

### 🔄 Method 4: Fallback
- **Configuration**: Used when all other methods are disabled
- **Flexibility**: None - uses original name
- **Consistency**: Variable - depends on input
- **Example**: `fallback`

## Comparison Examples

| Resource | Method | Configuration | Expected Result | Use Case |
|----------|--------|---------------|-----------------|----------|
| `local_module_example` | local_module | Global settings | `complocalmoduletest001` | Standard organizational naming |
| `azurecaf_example` | azurecaf | Force azurecaf | azurecaf output | Industry standard patterns |
| `passthrough_example` | passthrough | `passthrough = true` | `passthroughexample` | Exact name control |
| `custom_pattern` | local_module | Custom config | `custompattern_test_002_custom` | Team-specific patterns |
| `global_pattern` | local_module | Resource pattern | `compglobalpatterntest003` | Resource-optimized naming |
| `fallback_example` | fallback | All disabled | `fallback` | Fallback behavior |

## Method Selection Logic

The hybrid system uses this priority order:

```hcl
1. if (passthrough = true) → use exact name
2. elif (use_local_module = true) → use local naming module
3. elif (use_azurecaf = true) → use azurecaf provider
4. else → use fallback (original name)
```

## Configuration Examples

### Force azurecaf Method
```hcl
naming = {
  use_azurecaf     = true
  use_local_module = false
}
```

### Force Passthrough Method
```hcl
naming = {
  passthrough = true
}
```

### Custom Local Module Pattern
```hcl
naming = {
  separator       = "_"
  component_order = ["name", "environment", "instance", "prefix"]
  prefix          = "custom"
}
```

### Force Fallback Method
```hcl
naming = {
  use_azurecaf     = false
  use_local_module = false
  passthrough      = false
}
```

## Testing Commands

```bash
# Plan all examples
terraform plan -var-file="global_settings.tfvars" -var-file="resources.tfvars"

# Compare naming methods
terraform output -json | jq -r '
  to_entries[] | 
  select(.value.naming_config) |
  "\(.key): \(.value.naming_config.final_name) [\(.value.naming_config.naming_method)]"
'

# Show method-specific outputs
terraform output -json | jq '
  to_entries[] | 
  select(.value.naming_config) |
  {
    resource: .key,
    final_name: .value.naming_config.final_name,
    method: .value.naming_config.naming_method,
    config: .value.naming_config.effective_naming
  }
'
```

## Method Selection Guide

### Choose **Local Module** When:
- ✅ You want organizational consistency
- ✅ You need custom component orders
- ✅ You want full control over separators
- ✅ You have specific resource patterns

### Choose **azurecaf** When:
- ✅ You want industry standard patterns
- ✅ You're migrating from existing azurecaf usage
- ✅ You prefer established conventions
- ✅ You want automatic abbreviations

### Choose **Passthrough** When:
- ✅ You have exact naming requirements
- ✅ You're migrating existing resources
- ✅ You need maximum control
- ✅ You have external naming systems

### Choose **Fallback** When:
- ✅ You want minimal naming transformation
- ✅ You're testing or debugging
- ✅ You have simple naming needs
- ✅ You want to preserve original names

## Performance Comparison

| Method | Performance | Complexity | Maintainability | Flexibility |
|--------|-------------|------------|-----------------|-------------|
| local_module | Good | Medium | High | High |
| azurecaf | Good | Low | Medium | Medium |
| passthrough | Excellent | Very Low | Low | Maximum |
| fallback | Excellent | Very Low | Very Low | None |

## Migration Strategies

### From azurecaf to Local Module
1. Set `use_azurecaf = false, use_local_module = true`
2. Configure equivalent patterns in `resource_patterns`
3. Test with small resource sets
4. Gradually migrate resource groups

### From Manual to Hybrid
1. Start with `passthrough = true` for existing resources
2. Add local module patterns for new resources
3. Gradually migrate existing resources to patterns
4. Implement governance controls as needed
