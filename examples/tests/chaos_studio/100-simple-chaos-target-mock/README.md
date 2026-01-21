# Mock Test Example for Chaos Studio

This example is specifically designed for **Terraform mock tests** (`terraform test`) and is located in the `tests/` directory to clearly separate it from deployment examples.

## Differences from Deployment Example

- Uses **direct resource IDs** instead of key-based references
- Allows mock tests to pass without requiring actual resource creation
- Not intended for real Azure deployments

## Purpose

This configuration validates:
- ✅ Module syntax is correct
- ✅ All required variables are defined
- ✅ Resource planning succeeds
- ✅ No circular dependencies

## Running Mock Tests

```bash
cd examples
terraform test -test-directory=./tests/mock -var-file="tests/chaos_studio/100-simple-chaos-target-mock/configuration.tfvars" -verbose
```

## For Real Deployments

Use the deployment example in `chaos_studio/100-simple-chaos-target/` which uses key-based references:

```hcl
target_resource = {
  key = "test_storage"
}

chaos_studio_target = {
  key = "storage_target"
}
```

This approach allows resources to reference each other dynamically.
