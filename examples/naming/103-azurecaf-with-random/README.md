# Example 103: Azurecaf Naming with Random String

This example demonstrates using the azurecaf naming provider with random string generation for unique resource names.

## Configuration

- **Naming Method**: Azurecaf with random suffix
- **Random Length**: 4 characters
- **Random Seed**: Configurable per resource
- **Prefix**: "contoso"
- **Environment**: "prod"

## Expected Results

| Resource   | Expected Name Pattern         | Example                       |
| ---------- | ----------------------------- | ----------------------------- |
| chatbot    | `contoso-cog-chatbot-4x7a`    | `contoso-cog-chatbot-8k2m`    |
| translator | `contoso-cog-translator-9n3p` | `contoso-cog-translator-5r7w` |

## Usage

```bash
# Navigate to examples directory
cd /home/$USER/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Test the configuration
terraform_with_var_files \
  --dir /naming/103-azurecaf-with-random/ \
  --action plan \
  --auto auto \
  --workspace test
```

## Key Features

- **Random String Generation**: Ensures unique names across deployments
- **Configurable Random Seed**: Different seeds for different resources
- **Azurecaf Compliance**: Follows Azure naming conventions
- **Multiple Resources**: Shows how random strings differ per resource

## Global Settings

```hcl
global_settings = {
  default_region = "region1"
  environment    = "prod"
  prefix         = "contoso"
  random_length  = 4
  random_seed    = "chatbot"

  naming = {
    use_azurecaf      = true
    use_local_module  = false
  }
}
```

## Resource Configuration

```hcl
cognitive_services = {
  ai_services = {
    chatbot = {
      name               = "chatbot"
      sku_name          = "S0"
      resource_group_key = "main"
    }

    translator = {
      name               = "translator"
      sku_name          = "S1"
      resource_group_key = "main"
    }
  }
}
```

This example is useful for:

- Production environments requiring unique names
- Testing multiple deployments of the same configuration
- Understanding how azurecaf handles random string generation
