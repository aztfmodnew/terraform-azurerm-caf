# Azure Naming Convention Module

This module provides Azure resource naming conventions based on Microsoft's best practices and the official Azure naming guidelines. It supports both standalone usage and integration with the hybrid naming system in the CAF framework.

## Features

- **Microsoft-compliant naming**: Based on official Azure naming conventions
- **Resource-specific validation**: Each resource type has specific length and character constraints
- **Flexible naming patterns**: Support for prefix, suffix, environment, region, and instance components
- **Configurable component order**: Customize the order of naming components
- **Automatic validation**: Built-in validation checks for name length and allowed characters
- **Global uniqueness handling**: Automatic random suffix for globally unique resources
- **Clean input**: Option to remove invalid characters automatically
- **Hybrid naming integration**: Works seamlessly with azurecaf provider and passthrough modes

## Usage

### Basic Usage

```hcl
module "naming" {
  source = "./modules/naming"

  resource_type = "azurerm_storage_account"
  name          = "myapp"
  environment   = "prod"
  region        = "eus"
}

resource "azurerm_storage_account" "example" {
  name                = module.naming.result
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  account_tier        = "Standard"
  account_replication_type = "LRS"
}
```

### Advanced Usage with Component Order

```hcl
module "naming" {
  source = "./modules/naming"

  resource_type   = "azurerm_key_vault"
  name            = "secrets"
  environment     = "prod"
  region          = "eus"
  instance        = "01"
  prefix          = "company"
  suffix          = "main"
  separator       = "-"
  component_order = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]
  clean_input     = true
  add_random      = true
  random_length   = 4
  validate        = true
}

# Output: company-kv-secrets-prod-eus-01-main-a1b2
```

### Hybrid Naming System Integration

This module integrates with the CAF hybrid naming system, supporting three naming methods:

```hcl
# In a CAF module with hybrid naming
locals {
  use_local_module = try(var.global_settings.naming.use_local_module, false)
}

module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = "azurerm_storage_account"
  name            = var.settings.name
  environment     = var.global_settings.environment
  region          = var.global_settings.regions[var.global_settings.default_region]
  component_order = try(var.global_settings.naming.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"])
  clean_input     = var.global_settings.clean_input
  validate        = true
}
```

### Multiple Resources

```hcl
locals {
  resources = {
    storage_account = {
      resource_type = "azurerm_storage_account"
      name          = "data"
      add_random    = true
    }
    key_vault = {
      resource_type = "azurerm_key_vault"
      name          = "secrets"
      add_random    = true
    }
    app_service = {
      resource_type = "azurerm_linux_web_app"
      name          = "api"
      add_random    = true
    }
  }
}

module "naming" {
  source = "./modules/naming"

  for_each = local.resources

  resource_type = each.value.resource_type
  name          = each.value.name
  environment   = "prod"
  region        = "eus"
  add_random    = each.value.add_random
  random_length = 6
}
```

## Unsupported Resources in azurecaf

Some Azure resources are not supported by the azurecaf provider. For these resources, the hybrid naming system automatically uses the local naming module as the preferred method:

### Strategy for Unsupported Resources

1. **Prefer Local Module**: Default to `use_local_module = true` for unsupported resources
2. **Fallback to azurecaf**: Use closest supported resource type as fallback
3. **Seamless Experience**: Users don't need to know which resources are supported

### Examples of Unsupported Resources

- `azurerm_ai_services` → Falls back to `azurerm_cognitive_account`
- `azurerm_container_app` → Falls back to `azurerm_container_group`
- `azurerm_static_site` → Falls back to `azurerm_app_service`

For a complete list, see [UNSUPPORTED_RESOURCES.md](./UNSUPPORTED_RESOURCES.md).

### Implementation for Unsupported Resources

```hcl
locals {
  # For unsupported resources, prefer local module over azurecaf
  use_local_module  = !local.use_passthrough && try(var.global_settings.naming.use_local_module, true)  # Default to true
  use_azurecaf      = !local.use_passthrough && !local.use_local_module && try(var.global_settings.naming.use_azurecaf, false)  # Default to false
}
```

## Hybrid Naming System

The CAF framework uses a hybrid naming system that supports three methods:

1. **Passthrough**: Use exact names as provided
2. **Local Module**: Use this naming module with full customization
3. **Azurecaf Provider**: Use the azurecaf provider for backward compatibility

### Naming Method Priority

The hybrid system follows this priority order:

1. **Passthrough** (if `global_settings.passthrough = true`)
2. **Local Module** (if `global_settings.naming.use_local_module = true`)
3. **Azurecaf Provider** (if `global_settings.naming.use_azurecaf = true`)
4. **Fallback** (use original name)

### Plan-Time Visibility

The hybrid system provides plan-time visibility of generated names using `terraform_data`:

```hcl
# module.example.module.ai_services["simple_service"].terraform_data.naming_preview will be created
+ resource "terraform_data" "naming_preview" {
    + input  = {
        + base_name     = "chatbot"
        + final_name    = (known after apply)
        + naming_method = "local_module"
        + preview_name  = "company-cog-chatbot-prod-eus-01"
      }
  }
```

## Resource Types Supported

The module supports all major Azure resource types including:

- **Compute**: Virtual Machines, AKS, Container Instances, etc.
- **Storage**: Storage Accounts, Disks, etc.
- **Networking**: VNets, Subnets, Load Balancers, etc.
- **Database**: SQL Server, CosmosDB, Redis, etc.
- **Web**: App Services, Function Apps, etc.
- **Security**: Key Vault, Identity, etc.
- **AI/ML**: Cognitive Services, AI Services, etc.
- **Integration**: Event Grid, Service Bus, etc.

## Naming Convention

The module follows Microsoft's recommended naming convention:

```
[prefix]-[abbreviation]-[name]-[environment]-[region]-[instance]-[suffix]
```

### Examples

| Resource Type   | Generated Name             | Pattern                          |
| --------------- | -------------------------- | -------------------------------- |
| Storage Account | `stmyappprodeus01`         | `st-myapp-prod-eus-01` (cleaned) |
| Key Vault       | `kv-secrets-prod-eus-01`   | `kv-secrets-prod-eus-01`         |
| AKS Cluster     | `aks-cluster-prod-eus-01`  | `aks-cluster-prod-eus-01`        |
| Web App         | `app-frontend-prod-eus-01` | `app-frontend-prod-eus-01`       |

## Variables

| Name            | Description                            | Type   | Default                                                                             | Required |
| --------------- | -------------------------------------- | ------ | ----------------------------------------------------------------------------------- | -------- |
| resource_type   | The type of Azure resource             | string | -                                                                                   | yes      |
| name            | Base name for the resource             | string | -                                                                                   | yes      |
| environment     | Environment name (dev, prod, etc.)     | string | ""                                                                                  | no       |
| region          | Azure region abbreviation              | string | ""                                                                                  | no       |
| instance        | Instance number or identifier          | string | ""                                                                                  | no       |
| prefix          | Prefix to add to the resource name     | string | ""                                                                                  | no       |
| suffix          | Suffix to add to the resource name     | string | ""                                                                                  | no       |
| separator       | Character used to separate components  | string | "-"                                                                                 | no       |
| component_order | Order of naming components             | list   | `["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]` | no       |
| clean_input     | Clean invalid characters from name     | bool   | true                                                                                | no       |
| add_random      | Add random suffix for unique resources | bool   | false                                                                               | no       |
| random_length   | Length of random suffix                | number | 4                                                                                   | no       |
| validate        | Validate the generated name            | bool   | true                                                                                | no       |

## Outputs

| Name          | Description                                   |
| ------------- | --------------------------------------------- |
| result        | The generated resource name                   |
| abbreviation  | The abbreviation used for the resource type   |
| components    | The name components used to build the name    |
| constraints   | The naming constraints applied                |
| validation    | Validation information for the generated name |
| random_suffix | The random suffix that was added (if any)     |
| raw_name      | The raw name before applying constraints      |

## Resource Constraints

Each resource type has specific constraints based on Azure requirements:

### Storage Account

- Length: 3-24 characters
- Characters: lowercase letters and numbers only
- Global unique: Yes

### Key Vault

- Length: 3-24 characters
- Characters: letters, numbers, and hyphens
- Global unique: Yes

### Virtual Network

- Length: 2-64 characters
- Characters: letters, numbers, hyphens, underscores, and periods
- Global unique: No

## Environment Abbreviations

Common environment abbreviations:

- `dev` - Development
- `test` - Testing
- `stage` - Staging
- `prod` - Production
- `qa` - Quality Assurance

## Region Abbreviations

Common region abbreviations:

- `eus` - East US
- `wus` - West US
- `neu` - North Europe
- `weu` - West Europe
- `sea` - Southeast Asia

## Best Practices

1. **Use consistent naming**: Apply the same pattern across all resources
2. **Enable validation**: Keep `validate = true` to catch naming issues early
3. **Use random suffixes**: For globally unique resources, enable `add_random = true`
4. **Clean input**: Use `clean_input = true` to handle invalid characters
5. **Document patterns**: Maintain documentation of your naming conventions

## Migration from azurecaf_name

If migrating from the `azurecaf_name` provider to the local naming module:

```hcl
# Before (azurecaf_name provider)
resource "azurecaf_name" "example" {
  name          = "myapp"
  resource_type = "azurerm_storage_account"
  prefixes      = ["company"]
  suffixes      = ["main"]
  use_slug      = true
  clean_input   = true
}

# After (local naming module)
module "naming" {
  source = "./modules/naming"

  resource_type = "azurerm_storage_account"
  name          = "myapp"
  prefix        = "company"
  suffix        = "main"
  clean_input   = true
}
```

## Hybrid Naming Configuration

To use the hybrid naming system in your CAF modules:

```hcl
# In global_settings
global_settings = {
  naming = {
    use_azurecaf      = true   # Use azurecaf provider (default)
    use_local_module  = false  # Use local naming module
    component_order   = ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"]
  }
  passthrough = false  # Use exact names (highest priority)
}
```

## Examples

### Basic Local Module Usage

```hcl
module "naming" {
  source = "./modules/naming"

  resource_type = "azurerm_storage_account"
  name          = "data"
  environment   = "prod"
  region        = "eus"
  instance      = "01"
}

# Output: st-data-prod-eus-01
```

### Custom Component Order

```hcl
module "naming" {
  source = "./modules/naming"

  resource_type   = "azurerm_key_vault"
  name            = "secrets"
  environment     = "prod"
  region          = "eus"
  component_order = ["abbreviation", "name", "instance", "environment", "region"]
}

# Output: kv-secrets-01-prod-eus
```

## Contributing

To add support for new resource types:

1. Add the resource type to the `resource_abbreviations` map
2. Add the resource constraints to the `resource_constraints` map
3. Add validation for the resource type in `variables.tf`
4. Update this README with the new resource type
