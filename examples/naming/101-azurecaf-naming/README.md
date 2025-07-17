# Basic azurecaf Naming Example

This example demonstrates the default naming method using the azurecaf provider.

## What This Example Shows

- Standard azurecaf naming (current production method)
- Basic configuration with minimal settings
- Default CAF naming conventions

## Expected Result

**Service Name**: `caf-cog-chatbot-001`

**Format**: `{prefix}-{abbreviation}-{name}-{suffix}`

## How to Run

```bash
cd /home/$USER/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform_with_var_files \
  --dir /naming/100-azurecaf-naming/ \
  --action plan \
  --auto auto \
  --workspace test
```

## Key Configuration

- **naming.use_azurecaf**: `true` (default)
- **naming.use_local_module**: `false` (default)
- **Prefix**: `caf`
- **Suffix**: `001`
- **Environment**: `test`

This is the baseline configuration that most existing CAF deployments use.
