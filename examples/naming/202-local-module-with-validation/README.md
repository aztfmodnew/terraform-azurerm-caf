# Example 202: Local Module with Validation

This example demonstrates the local naming module with built-in validation features and per-resource overrides.

## Configuration

- **Naming Method**: Local naming module
- **Validation**: Enabled (validates name length, characters, etc.)
- **Component Order**: `["prefix", "abbreviation", "name", "environment", "region", "suffix"]`
- **Per-Resource Overrides**: Different environments and regions

## Expected Results

| Resource             | Configuration   | Expected Name                         |
| -------------------- | --------------- | ------------------------------------- |
| valid_service        | prod/eastus/001 | `contoso-cog-chatbot-prod-eus-001`    |
| custom_order_service | test/westus/002 | `contoso-cog-translator-test-wus-002` |

## Usage

```bash
# Navigate to examples directory
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Test the configuration
terraform_with_var_files \
  --dir /naming/202-local-module-with-validation/ \
  --action plan \
  --auto auto \
  --workspace test

# To test validation errors, uncomment the invalid_service in configuration.tfvars
```

## Key Features

- **Built-in Validation**: Checks name length, character restrictions, etc.
- **Per-Resource Overrides**: Different environment/region per resource
- **Flexible Component Order**: Configurable name structure
- **Rich Outputs**: Provides validation details and naming method used

## Global Settings

```hcl
global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "contoso"
  suffix         = "001"

  naming = {
    use_azurecaf      = false
    use_local_module  = true
    component_order   = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
  }
}
```

## Resource Configuration with Overrides

```hcl
cognitive_services = {
  ai_services = {
    valid_service = {
      name               = "chatbot"
      sku_name          = "S0"
      resource_group_key = "main"

      # Override global settings
      environment = "prod"
      region      = "eastus"
      instance    = "001"
    }

    custom_order_service = {
      name               = "translator"
      sku_name          = "S1"
      resource_group_key = "main"

      # Different overrides
      environment = "test"
      region      = "westus"
      instance    = "002"
    }
  }
}
```

## Validation Features

The local naming module provides:

- **Length Validation**: Ensures names don't exceed Azure limits
- **Character Validation**: Checks for valid characters per resource type
- **Pattern Validation**: Validates naming patterns
- **Uniqueness**: Helps ensure unique names across deployments

## Testing Validation

To test validation errors, uncomment the `invalid_service` resource in `configuration.tfvars`:

```hcl
invalid_service = {
  name               = "this-name-is-way-too-long-for-cognitive-services-and-should-fail-validation"
  sku_name          = "S0"
  resource_group_key = "main"
}
```

This example is useful for:

- Understanding validation capabilities
- Testing per-resource configuration overrides
- Seeing how the local module handles different scenarios
