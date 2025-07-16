# Naming Examples

This directory contains examples demonstrating the hybrid naming system in the CAF framework.

## Available Examples

### 100-xxx: Basic Examples

- **[101-azurecaf-naming](101-azurecaf-naming/)**: Standard azurecaf naming (current production method)
- **[102-passthrough-naming](102-passthrough-naming/)**: Exact names without transformation
- **[103-azurecaf-with-random](103-azurecaf-with-random/)**: Azurecaf naming with random string generation

### 200-xxx: Intermediate Examples

- **[201-local-module-naming](201-local-module-naming/)**: Local naming module with validation
- **[202-local-module-with-validation](202-local-module-with-validation/)**: Local module with validation features

### 300-xxx: Advanced Examples

- **[301-custom-component-order](301-custom-component-order/)**: Custom component ordering patterns
- **[302-environment-specific-naming](302-environment-specific-naming/)**: Different naming strategies per environment

### 400-xxx: Complex Examples

- **[401-hybrid-naming-comparison](401-hybrid-naming-comparison/)**: Comparison of all naming methods

## Naming Methods Overview

| Method           | Description              | Configuration                    | Best For                         |
| ---------------- | ------------------------ | -------------------------------- | -------------------------------- |
| **azurecaf**     | Uses azurecaf provider   | `naming.use_azurecaf = true`     | Production, existing deployments |
| **local_module** | Uses local naming module | `naming.use_local_module = true` | Validation, custom orders        |
| **passthrough**  | Exact names              | `passthrough = true`             | Legacy systems, manual control   |

## Priority Order

1. **Passthrough** (if `passthrough = true`)
2. **Local Module** (if `naming.use_local_module = true`)
3. **Azurecaf** (if `naming.use_azurecaf = true`)
4. **Fallback** (original name)

## Getting Started

1. **Start with 100-azurecaf-naming** to understand the baseline
2. **Try 200-local-module-naming** to see the new features
3. **Explore 300-custom-component-order** for advanced patterns
4. **Use 400-hybrid-naming-comparison** to compare all methods

## Common Configuration

All examples use this basic structure:

```hcl
global_settings = {
  default_region = "region1"
  environment    = "test"
  prefix         = "caf"
  suffix         = "001"

  regions = {
    region1 = "eastus"
  }

  naming = {
    use_azurecaf      = true  # or false
    use_local_module  = false # or true
    component_order   = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
  }
}
```

## Testing

All examples can be tested using:

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform_with_var_files \
  --dir /naming/[example-directory]/ \
  --action plan \
  --auto auto \
  --workspace test
```

## Migration Guide

### From azurecaf to local module:

1. Set `naming.use_azurecaf = false`
2. Set `naming.use_local_module = true`
3. Test with example 200-local-module-naming

### From manual names to structured:

1. Start with passthrough (100-passthrough-naming)
2. Gradually adopt local module (200-local-module-naming)
3. Customize as needed (300-custom-component-order)

## Support

Each example directory contains:

- `configuration.tfvars`: Complete configuration
- `README.md`: Detailed explanation and expected results
- Comments explaining the naming outcomes
