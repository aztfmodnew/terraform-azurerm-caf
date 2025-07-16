# Advanced Custom Component Order Example

This example demonstrates advanced naming patterns with custom component ordering.

## What This Example Shows

- Custom component ordering (global and per-resource)
- Flexible naming patterns
- Minimal component configurations
- Complex naming scenarios

## Expected Results

| Service | Component Order | Expected Name | Pattern |
|---------|----------------|---------------|---------|
| global_custom_service | name-abbr-env-region-instance-prefix-suffix | `chatbot-cog-prod-eus-01-acme-v1` | Global custom order |
| resource_custom_service | prefix-name-env-region-instance-suffix | `acme-analyzer-production-wus-02-v1` | Resource-specific order |
| minimal_service | name-abbr-env | `simple-cog-prod` | Minimal components |

## How to Run

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform_with_var_files \
  --dir /naming/300-custom-component-order/ \
  --action plan \
  --auto auto \
  --workspace prod
```

## Key Configuration

### Global Custom Order
```hcl
component_order = ["name", "abbreviation", "environment", "region", "instance", "prefix", "suffix"]
```

### Resource-Specific Override
```hcl
component_order = ["prefix", "name", "environment", "region", "instance", "suffix"]
```

### Minimal Components
```hcl
component_order = ["name", "abbreviation", "environment"]
```

## Available Components

- **prefix**: Organization or project prefix
- **abbreviation**: Azure resource type abbreviation
- **name**: Resource base name
- **environment**: Environment identifier
- **region**: Azure region abbreviation
- **instance**: Instance number or identifier
- **suffix**: Version or iteration suffix

## Use Cases

- **Custom naming standards**: Adapt to organization-specific patterns
- **Legacy compatibility**: Match existing naming conventions
- **Simplified names**: Use minimal components for development
- **Complex scenarios**: Multi-environment, multi-region deployments

## Benefits

- **Complete flexibility**: Any component order
- **Per-resource control**: Override global settings
- **Validation maintained**: Azure compliance regardless of order
- **Backwards compatible**: Works with existing configurations
