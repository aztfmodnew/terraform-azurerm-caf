# Unsupported Resources in azurecaf Provider

This document lists Azure resources that are not supported by the azurecaf provider and how to handle them in the hybrid naming system.

## Strategy for Unsupported Resources

For resources not supported by azurecaf, we implement a fallback strategy:

1. **Prefer Local Module**: Default to `use_local_module = true` for unsupported resources
2. **Fallback to azurecaf**: Use closest supported resource type as fallback
3. **Document mappings**: Maintain clear documentation of fallback mappings

## Unsupported Resources and Their Fallbacks

### AI/Cognitive Services

| Resource Type                                    | azurecaf Support | Fallback                    | Local Module Abbrev |
| ------------------------------------------------ | ---------------- | --------------------------- | ------------------- |
| `azurerm_ai_services`                            | ❌ No            | `azurerm_cognitive_account` | `ai`                |
| `azurerm_cognitive_deployment`                   | ❌ No            | `azurerm_cognitive_account` | `cog-deploy`        |
| `azurerm_cognitive_account_customer_managed_key` | ❌ No            | `azurerm_cognitive_account` | `cog-cmk`           |

### Container Services

| Resource Type                       | azurecaf Support | Fallback                  | Local Module Abbrev |
| ----------------------------------- | ---------------- | ------------------------- | ------------------- |
| `azurerm_container_app`             | ❌ No            | `azurerm_container_group` | `ca`                |
| `azurerm_container_app_environment` | ❌ No            | `azurerm_container_group` | `cae`               |
| `azurerm_container_app_job`         | ❌ No            | `azurerm_container_group` | `caj`               |

### Networking (Advanced)

| Resource Type                                   | azurecaf Support | Fallback                         | Local Module Abbrev |
| ----------------------------------------------- | ---------------- | -------------------------------- | ------------------- |
| `azurerm_private_dns_zone_virtual_network_link` | ❌ No            | `azurerm_private_dns_zone`       | `pdz-vnet-link`     |
| `azurerm_network_security_rule`                 | ❌ No            | `azurerm_network_security_group` | `nsg-rule`          |

### Web/App Services (Advanced)

| Resource Type                       | azurecaf Support | Fallback              | Local Module Abbrev |
| ----------------------------------- | ---------------- | --------------------- | ------------------- |
| `azurerm_static_site`               | ❌ No            | `azurerm_app_service` | `stapp`             |
| `azurerm_static_site_custom_domain` | ❌ No            | `azurerm_app_service` | `stapp-domain`      |

## Implementation Pattern

For any unsupported resource, follow this pattern in the module's `naming.tf`:

```hcl
locals {
  # For unsupported resources, prefer local module over azurecaf
  use_passthrough   = var.global_settings.passthrough
  use_local_module  = !local.use_passthrough && try(var.global_settings.naming.use_local_module, true)  # Default to true
  use_azurecaf      = !local.use_passthrough && !local.use_local_module && try(var.global_settings.naming.use_azurecaf, false)  # Default to false

  base_name = var.settings.name
}

# Local naming module (preferred for unsupported resources)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = "azurerm_actual_resource_type"  # Use actual resource type
  name            = local.base_name
  environment     = try(var.settings.environment, var.global_settings.environment, "")
  region          = try(var.settings.region, try(var.global_settings.regions[var.global_settings.default_region], ""), "")
  instance        = try(var.settings.instance, "")
  prefix          = try(var.settings.prefix, try(var.global_settings.prefix, ""))
  suffix          = try(var.settings.suffix, try(var.global_settings.suffix, ""))
  separator       = var.global_settings.separator
  component_order = try(var.settings.component_order, var.global_settings.naming.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"])
  clean_input     = var.global_settings.clean_input
  validate        = true
}

# azurecaf naming (fallback with closest supported type)
resource "azurecaf_name" "resource_name" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_fallback_resource_type"  # Use closest supported type
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}

# Improved preview name for local module
locals {
  preview_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? join("-", compact([
      try(var.settings.prefix, try(var.global_settings.prefix, ""), ""),
      "resource_abbrev",  # Use appropriate abbreviation
      local.base_name,
      try(var.settings.environment, var.global_settings.environment, ""),
      try(var.settings.region, try(var.global_settings.regions[var.global_settings.default_region], ""), ""),
      try(var.settings.instance, ""),
      try(var.settings.suffix, try(var.global_settings.suffix, ""), "")
    ])) : (
      local.use_azurecaf ? join("-", compact([
        try(var.global_settings.prefixes[0], ""),
        "fallback_abbrev",  # Use fallback abbreviation
        local.base_name,
        try(var.global_settings.suffixes[0], "")
      ])) : local.base_name
    )
  )
}
```

## Benefits of This Approach

1. **Seamless Experience**: Users don't need to know which resources are supported
2. **Consistent Naming**: All resources follow the same naming patterns
3. **Flexible Fallbacks**: Graceful degradation when azurecaf doesn't support a resource
4. **Future-Proof**: Easy to switch to azurecaf when support is added
5. **Better Preview**: Users can see predicted names during plan for all resources

## Adding New Unsupported Resources

When adding support for a new unsupported resource:

1. Add the resource to the table above
2. Implement the naming pattern in the module
3. Add appropriate abbreviation to the naming module
4. Test with all three naming methods
5. Update examples if needed

## Migration Strategy

When azurecaf adds support for a currently unsupported resource:

1. Update the defaults to prefer azurecaf again
2. Add the new resource type to azurecaf configuration
3. Update documentation
4. Test backwards compatibility
5. Provide migration examples if needed
