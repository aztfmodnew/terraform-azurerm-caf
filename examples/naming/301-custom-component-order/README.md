# Advanced Custom Component Order Example

This example demonstrates advanced naming patterns with custom component ordering using the **hybrid naming system**.

## What This Example Shows

- Custom component ordering (global and per-resource)
- Individual resource naming overrides with `naming` block
- Flexible naming patterns with hybrid governance
- Minimal and complex component configurations
- Different separators and environment overrides

## Expected Results

| Service | Component Order | Expected Name | Pattern |
|---------|----------------|---------------|---------|
| global_custom_service | name-abbr-env-region-instance-prefix-suffix | `chatbot-ai-prod-eus-01-acme-v1` | Global custom order |
| resource_custom_service | prefix-name-env-region-instance-suffix | `acme-analyzer-stg-wus-02-v1` | Individual override |
| minimal_service | name-abbr-env | `simple-ai-prod` | Minimal components |
| complex_custom | abbr-prefix-name-env-instance-suffix | `ai_org_processor_dev_03_beta` | Complex custom pattern |

## How to Run

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform_with_var_files 
  --dir ./naming/301-custom-component-order/ 
  --action plan 
  --auto auto 
  --workspace prod
```

## Key Configuration

### Global Custom Order (in global_settings)
```hcl
naming = {
  use_azurecaf              = false
  use_local_module          = true
  allow_resource_override   = true
  component_order           = ["name", "abbreviation", "environment", "region", "instance", "prefix", "suffix"]
}
```

### Individual Resource Override (in naming block)
```hcl
ai_services = {
  my_service = {
    name = "analyzer"
    naming = {
      environment     = "staging"
      component_order = ["prefix", "name", "environment", "region", "instance", "suffix"]
    }
  }
}
```

### Minimal Components
```hcl
ai_services = {
  simple_service = {
    name = "simple"
    naming = {
      component_order = ["name", "abbreviation", "environment"]
    }
  }
}
```

## Available Components

- **prefix**: Organization or project prefix
- **abbreviation**: Azure resource type abbreviation
- **name**: Resource base name
- **environment**: Environment identifier
- **region**: Azure region abbreviation
- **instance**: Instance number or identifier
- **suffix**: Version or iteration suffix

## Hybrid Naming System Features

This example demonstrates the hybrid naming system capabilities:

### Governance Controls
- `allow_resource_override = true`: Enables individual resource customization
- Global patterns provide defaults, individual `naming` blocks override as needed
- Fallback hierarchy: individual → global → defaults

### Resource-Level Customization
```hcl
ai_services = {
  my_service = {
    naming = {
      prefix          = "custom"      # Override global prefix
      separator       = "_"          # Override global separator  
      environment     = "dev"        # Override global environment
      component_order = [...]        # Override global component order
    }
  }
}
```

### Outputs and Debugging
Each resource outputs:
- `name`: Final computed name
- `naming_method`: "local_module" (for this example)
- `naming_config`: Complete metadata including effective configuration applied

## Use Cases

- **Custom naming standards**: Adapt to organization-specific patterns
- **Legacy compatibility**: Match existing naming conventions
- **Simplified names**: Use minimal components for development environments
- **Complex scenarios**: Multi-environment, multi-region deployments with custom separators
- **Individual control**: Override global settings per resource when needed
- **Governance compliance**: Maintain organizational standards while allowing flexibility

## Benefits

- **Complete flexibility**: Any component order with hybrid governance
- **Individual resource control**: Override global settings with `naming` block
- **Validation maintained**: Azure compliance regardless of component order
- **Backwards compatible**: Works with existing configurations
- **Governance support**: `allow_resource_override` controls individual customization
- **Transparent debugging**: `naming_config` output shows all applied settings
