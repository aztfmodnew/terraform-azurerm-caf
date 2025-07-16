# Advanced Hybrid Naming Comparison Example

This example demonstrates all the naming methods available in the hybrid naming system by creating multiple AI Services with different naming configurations.

## What This Example Shows

- **azurecaf naming** (default global setting)
- **local module naming** (resource-level override)
- **passthrough naming** (exact names)
- **custom component order** (advanced configuration)

## Resources Created

1. **azurecaf_service**: Uses global azurecaf naming
2. **local_module_service**: Overrides to use local module naming
3. **passthrough_service**: Uses exact name without transformation
4. **custom_order_service**: Uses custom component order with local module

## Expected Results

| Service | Naming Method | Expected Name | Components |
|---------|---------------|---------------|------------|
| azurecaf_service | azurecaf | `caf-cog-chatbot-001` | azurecaf format |
| local_module_service | local_module | `caf-cog-translator-demo-eus-001` | prefix-abbr-name-env-region-suffix |
| passthrough_service | passthrough | `my-exact-ai-service-name` | exact name |
| custom_order_service | custom_order | `analyzer-prod-wus-02-001` | name-env-region-instance-suffix |

## How to Run

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Plan the deployment
terraform_with_var_files \
  --dir /naming/400-hybrid-naming-comparison/ \
  --action plan \
  --auto auto \
  --workspace demo

# Apply the configuration
terraform_with_var_files \
  --dir /naming/400-hybrid-naming-comparison/ \
  --action apply \
  --auto auto \
  --workspace demo
```

## Key Configuration Points

### Global Settings
- Default naming method: `azurecaf`
- Global prefix: `caf`
- Global suffix: `001`
- Environment: `demo`

### Resource-Level Overrides
- Each service can override the global naming method
- Custom component order per resource
- Environment and region overrides supported

### Outputs
Each service will output:
- `name`: The final resolved name
- `naming_method`: The method used (azurecaf, local_module, passthrough, fallback)
- Standard AI Services outputs (id, endpoint, etc.)

## Learning Points

1. **Flexibility**: Different naming methods can coexist in the same configuration
2. **Gradual Migration**: You can test local module naming on specific resources
3. **Backwards Compatibility**: Existing azurecaf configurations work unchanged
4. **Customization**: Component order and naming logic can be tailored per resource

This example is ideal for:
- Testing the hybrid naming system
- Comparing naming outputs
- Understanding migration paths
- Learning advanced configuration patterns
