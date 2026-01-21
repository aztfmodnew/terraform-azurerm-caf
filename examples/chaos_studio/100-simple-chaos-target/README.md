# Simple Chaos Studio Target Example

This example demonstrates how to enable Azure Chaos Studio on a Storage Account using key-based references.

## What This Example Creates

1. **Resource Group** - Container for the resources
2. **Storage Account** - The target resource for chaos experiments
3. **Chaos Studio Target** - Registers the storage account with Chaos Studio
4. **Chaos Studio Capability** - Enables the "Failover" fault capability

## Key Features

- ✅ **Key-based references** - Resources reference each other by key (e.g., `key = "test_storage"`)
- ✅ **Automatic dependency resolution** - Framework resolves resource IDs using `remote_objects` pattern
- ✅ **Production-ready pattern** - Same approach works for cross-landing-zone references

## Configuration Pattern

```hcl
# Reference storage account by key
target_resource = {
  key = "test_storage"
}

# Reference chaos target by key
chaos_studio_target = {
  key = "storage_target"
}
```

## Deployment

```bash
# From repository root
cd examples
terraform_with_var_files --dir /chaos_studio/100-simple-chaos-target/ --action plan --auto auto --workspace test
```

## For Mock Tests

If you need to run `terraform test` with mock providers, use the test configuration in `tests/`:

```bash
cd examples
terraform test -test-directory=./tests/mock -var-file="tests/chaos_studio/100-simple-chaos-target-mock/configuration.tfvars"
```

See `../../tests/chaos_studio/100-simple-chaos-target-mock/` for the mock test configuration.

## Next Steps

After deployment:
1. Go to Azure Portal → Chaos Studio
2. You'll see your storage account listed as a target
3. The "Failover-1.0" capability will be enabled
4. You can now create chaos experiments using this target

## Related Examples

- `../../tests/chaos_studio/100-simple-chaos-target-mock/` - Mock test version with direct IDs
- (Future) `200-chaos-experiment/` - Creating and running chaos experiments
