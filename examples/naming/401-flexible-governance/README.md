# Flexible Governance Example

This example demonstrates the **flexible governance** mode of the hybrid naming system, where organizations maintain control while allowing teams to customize naming patterns for their specific needs.

## Key Features

- ✅ **Individual Overrides Allowed**: `allow_resource_override = true`
- ✅ **Resource-Specific Patterns**: Default patterns for different Azure resource types
- ✅ **Team Flexibility**: Teams can override naming for their specific requirements
- ✅ **Organizational Standards**: Base patterns ensure consistency

## Governance Model

```hcl
naming = {
  allow_resource_override = true    # Enables team customization
  resource_patterns = {             # Organizational defaults
    azurerm_storage_account = {
      separator = ""                # No separators for storage accounts
    }
    azurerm_key_vault = {
      separator = "-"               # Hyphens for key vaults
    }
  }
}
```

## Examples Included

### 1. Global Pattern Usage
- **Resource**: Storage Account `global_pattern`
- **Result**: `org-st-myapp-prod-westeurope-001`
- **Method**: Uses global configuration without overrides

### 2. Team Environment Override
- **Resource**: Container App Environment `dev_override`
- **Result**: `team1_cae_devapp_dev_test`
- **Method**: Team overrides prefix, environment, separator, and suffix

### 3. Project-Specific Naming
- **Resource**: Key Vault `project_vault`
- **Result**: `proj-secrets-shared-westeurope`
- **Method**: Project overrides prefix, environment, and component order

### 4. Resource Pattern Based
- **Resource**: Storage Account `pattern_based`
- **Result**: `orglogsproduction001`
- **Method**: Uses resource pattern (no separators for storage accounts)

## Testing Commands

```bash
# Plan the configuration
terraform plan -var-file="global_settings.tfvars" -var-file="resources.tfvars"

# Show naming outputs
terraform output -json | jq '.*.value.naming_config'

# Validate naming methods
terraform output -json | jq '.*.value.naming_method'
```

## Use Cases

1. **Multi-Team Organizations**: Different teams can adapt naming to their workflows
2. **Project-Specific Requirements**: Special projects can use custom naming patterns
3. **Environment Differentiation**: Development vs production naming variations
4. **Resource Type Optimization**: Different patterns for different Azure services

## Benefits

- **🎯 Flexibility**: Teams can customize naming for their specific needs
- **🛡️ Governance**: Organizational patterns provide consistency baseline
- **📊 Transparency**: Full visibility into naming decisions and methods
- **🔄 Adaptability**: Easy to adjust patterns as requirements evolve
