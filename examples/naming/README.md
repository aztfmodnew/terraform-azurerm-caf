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

### 400-xxx: Hybrid Governance Examples

- **[401-flexible-governance](401-flexible-governance/)**: Organizational control with team flexibility
- **[402-strict-governance](402-strict-governance/)**: Enforced organizational standards without overrides
- **[403-resource-patterns](403-resource-patterns/)**: Different naming patterns optimized per Azure resource type
- **[404-naming-comparison](404-naming-comparison/)**: Side-by-side comparison of all naming methods

## Naming Methods Overview

| Method           | Description              | Configuration                    | Best For                         | Governance Level |
| ---------------- | ------------------------ | -------------------------------- | -------------------------------- | ---------------- |
| **azurecaf**     | Uses azurecaf provider   | `naming.use_azurecaf = true`     | Production, existing deployments | Medium           |
| **local_module** | Uses local naming module | `naming.use_local_module = true` | Validation, custom orders        | High             |
| **passthrough**  | Exact names              | `passthrough = true`             | Legacy systems, manual control   | None             |
| **hybrid**       | Combines all methods     | `allow_resource_override = true` | Organizational flexibility       | Variable         |

## Governance Models

| Model | Override Allowed | Resource Patterns | Individual Naming | Use Case |
|-------|------------------|-------------------|-------------------|----------|
| **Flexible** | ✅ Yes | ✅ Suggested | ✅ Full override | Multi-team organizations |
| **Strict** | ❌ No | ✅ Enforced | ❌ Ignored | Compliance-heavy environments |
| **Resource-Optimized** | ✅ Limited | ✅ Per-type | ✅ Within patterns | Service-specific optimization |
| **Comparison** | ✅ Method-level | ✅ Configurable | ✅ Method-specific | Testing and migration |

## Priority Order

1. **Passthrough** (if `passthrough = true`)
2. **Local Module** (if `naming.use_local_module = true`)
3. **Azurecaf** (if `naming.use_azurecaf = true`)
4. **Fallback** (original name)

## Getting Started

### Quick Start Path
1. **[101-azurecaf-naming](101-azurecaf-naming/)** - Understand the baseline azurecaf approach
2. **[201-local-module-naming](201-local-module-naming/)** - Explore local module capabilities
3. **[404-naming-comparison](404-naming-comparison/)** - Compare all methods side by side

### Governance Implementation Path
1. **[401-flexible-governance](401-flexible-governance/)** - Allow team customization with organizational control
2. **[402-strict-governance](402-strict-governance/)** - Enforce complete organizational consistency
3. **[403-resource-patterns](403-resource-patterns/)** - Optimize patterns for different Azure resource types

### Development Path
1. **[302-environment-specific-naming](302-environment-specific-naming/)** - Different strategies per environment
2. **[301-custom-component-order](301-custom-component-order/)** - Advanced pattern customization
3. **[202-local-module-with-validation](202-local-module-with-validation/)** - Validation and compliance features

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
    use_azurecaf            = true  # or false
    use_local_module        = false # or true
    allow_resource_override = true  # Enable individual resource customization
    component_order         = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]

    # Resource-specific patterns (400-hybrid-governance-system example)
    resource_patterns = {
      azurerm_storage_account = {
        separator = ""  # No separator for storage accounts
      }
    }
  }
}
```

## Testing

All examples can be tested using:

```bash
cd /home/$USER/source/github/aztfmodnew/terraform-azurerm-caf/examples

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
