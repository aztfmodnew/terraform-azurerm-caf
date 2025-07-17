# Strict Governance Example

This example demonstrates the **strict governance** mode of the hybrid naming system, where organizations enforce complete naming consistency without allowing any individual overrides.

## Key Features

- 🔒 **No Individual Overrides**: `allow_resource_override = false`
- 📋 **Mandatory Patterns**: All resources follow enforced organizational patterns
- ✅ **Complete Consistency**: Guaranteed naming compliance across all resources
- 🛡️ **Compliance Enforcement**: Individual naming blocks are ignored

## Governance Model

```hcl
naming = {
  allow_resource_override = false   # Strict enforcement
  resource_patterns = {             # Mandatory patterns
    azurerm_storage_account = {
      separator = ""                # Enforced: no separators
      component_order = [...]       # Enforced order
      validate = true               # Enforced validation
    }
  }
}
```

## Examples Included

### 1. Storage Account Pattern
- **Resource**: `corporate_data`
- **Result**: `corpstdataprod001`
- **Pattern**: No separators, specific component order
- **Enforcement**: All storage accounts follow this exact pattern

### 2. Key Vault Pattern  
- **Resource**: `main_vault`
- **Result**: `corp-kv-secrets-prod-westeurope`
- **Pattern**: Hyphen separators, includes region
- **Enforcement**: All key vaults follow this exact pattern

### 3. Container App Environment Pattern
- **Resource**: `production_env`
- **Result**: `corp-cae-webapp-prod-001-001`
- **Pattern**: Hyphen separators, includes instance and suffix
- **Enforcement**: All container app environments follow this pattern

### 4. Override Attempts Are Ignored
- **Resource**: `ignored_override`
- **Attempted Override**: `prefix = "team1"`, `separator = "_"`
- **Actual Result**: `corpstlogsprod003`
- **Behavior**: Individual naming blocks are completely ignored

## Benefits of Strict Governance

### ✅ Advantages
- **Complete Consistency**: All resources follow identical patterns
- **Compliance Guaranteed**: No deviation from organizational standards
- **Simplified Management**: No need to review individual naming decisions
- **Audit-Friendly**: Clear, predictable naming across entire organization

### ⚠️ Considerations
- **Reduced Flexibility**: Teams cannot adapt naming to specific needs
- **Change Management**: Pattern changes require global coordination
- **Team Autonomy**: Less control for individual teams/projects

## Testing Commands

```bash
# Verify strict enforcement
terraform plan -var-file="global_settings.tfvars" -var-file="resources.tfvars"

# Confirm naming patterns
terraform output -json | jq '.*.value.naming_config.effective_naming'

# Verify override attempts are ignored
terraform output -json | jq '.*.value.naming_config.allow_override'
```

## Use Cases

1. **Highly Regulated Industries**: Financial, healthcare, government sectors
2. **Large Enterprises**: Organizations requiring absolute naming consistency
3. **Compliance Requirements**: Environments with strict audit requirements
4. **Standardized Operations**: Organizations prioritizing operational consistency

## Implementation Notes

- Individual `naming` blocks in resources are **ignored**
- Only `resource_patterns` from global settings are applied
- `allow_resource_override = false` enforces this behavior
- All naming decisions are centralized and predictable
