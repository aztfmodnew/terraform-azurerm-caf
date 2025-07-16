# Basic Passthrough Naming Example

This example demonstrates passthrough naming, which uses exact names without any transformation.

## What This Example Shows

- Exact name usage (no prefixes, suffixes, or transformations)
- Passthrough configuration (existing CAF feature)
- Manual name control for special cases

## Expected Result

**Service Name**: `my-exact-ai-service-name`

**Format**: Exact name as provided

## How to Run

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

terraform_with_var_files \
  --dir /naming/100-passthrough-naming/ \
  --action plan \
  --auto auto \
  --workspace test
```

## Key Configuration

- **passthrough**: `true` (takes priority over naming methods)
- **No naming transformation**: Names are used exactly as provided

## Use Cases

- Legacy system integration
- Specific naming requirements
- Manual name control
- Testing and development
