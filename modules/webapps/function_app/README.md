# Function App Module - DEPRECATED ⚠️

**⚠️ This module is DEPRECATED and will be removed in a future version.**

## Migration Path

This module uses the deprecated `azurerm_function_app` resource. Please migrate to one of the modern alternatives:

- **For Linux Function Apps**: Use `modules/webapps/linux_function_app/`
- **For Windows Function Apps**: Use `modules/webapps/windows_function_app/`

## Why This Module is Deprecated

The `azurerm_function_app` resource has been deprecated by HashiCorp in favor of:

- `azurerm_linux_function_app` - For Linux-based Function Apps
- `azurerm_windows_function_app` - For Windows-based Function Apps

These new resources provide:

- Better OS-specific configuration options
- Improved security features
- Support for modern Azure Function App features
- Better alignment with Azure's service model

## Migration Guide

### Example Configuration Migration

**Old (Deprecated):**

```hcl
function_apps = {
  my_function_app = {
    name                = "my-function-app"
    resource_group_key  = "my_rg"
    app_service_plan_key = "my_plan"
    settings = {
      os_type = "linux"
      # ... other settings
    }
  }
}
```

**New (Linux Function App):**

```hcl
linux_function_apps = {
  my_function_app = {
    name               = "my-function-app"
    resource_group_key = "my_rg"
    service_plan_key   = "my_plan"
    # ... other settings
  }
}
```

**New (Windows Function App):**

```hcl
windows_function_apps = {
  my_function_app = {
    name               = "my-function-app"
    resource_group_key = "my_rg"
    service_plan_key   = "my_plan"
    # ... other settings
  }
}
```

### Key Changes in Migration

1. **Module Selection**: Choose `linux_function_app` or `windows_function_app` based on your OS requirement
2. **Service Plan**: Use `service_plan_key` instead of `app_service_plan_key`
3. **OS Configuration**: OS-specific settings are now handled at the module level
4. **Schema Updates**: Some settings may have different property names in the new resources

### Breaking Changes

- `azurerm_function_app` resource is deprecated and will be removed
- Some configuration properties may have changed names
- OS-specific configurations are now handled differently

## Support Timeline

- **Current**: Module still works but shows deprecation warnings
- **Future Release**: Module will be removed entirely

Please plan your migration accordingly and update your configurations to use the modern Function App modules.
