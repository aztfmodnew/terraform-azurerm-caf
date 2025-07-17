# Intermediate Local Module Naming Example

This example demonstrates the local naming module with validation and flexible component ordering.

## What This Example Shows

- Local naming module usage (new feature)
- Built-in validation and Azure compliance
- Component-based name construction
- Regional and instance variations

## Expected Results

| Service | Expected Name | Components |
|---------|---------------|------------|
| main_service | `contoso-cog-chatbot-staging-eus-001` | prefix-abbr-name-env-region-suffix |
| regional_service | `contoso-cog-translator-staging-wus-02-001` | prefix-abbr-name-env-region-instance-suffix |

## How to Run

```bash
cd /home/$USER/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform_with_var_files \
  --dir /naming/200-local-module-naming/ \
  --action plan \
  --auto auto \
  --workspace staging
```

## Key Configuration

- **naming.use_local_module**: `true`
- **naming.use_azurecaf**: `false`
- **component_order**: Standard CAF order
- **Validation**: Automatic Azure compliance checking
- **Regional variations**: Different regions per service

## Benefits

- **Validation**: Built-in Azure naming validation
- **Flexibility**: Configurable component order
- **Consistency**: Standardized abbreviations
- **Debugging**: Clear component breakdown
- **No external dependencies**: Pure Terraform locals
