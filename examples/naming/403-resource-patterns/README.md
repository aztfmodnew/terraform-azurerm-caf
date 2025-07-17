# Resource Pattern Specialization Example

This example demonstrates how the hybrid naming system can apply **different naming patterns optimized for different Azure resource types**, taking into account each service's specific naming constraints and requirements.

## Key Features

- 🎯 **Resource-Specific Patterns**: Each Azure resource type has optimized naming rules
- 📏 **Constraint Awareness**: Patterns respect Azure naming limitations
- 🔧 **Optimization**: Different separators and component orders per resource type
- 📊 **Consistency**: Predictable patterns within each resource category

## Resource Pattern Strategy

### Storage Accounts
```hcl
azurerm_storage_account = {
  separator = ""                    # No separators (Azure constraint)
  component_order = ["prefix", "name", "environment", "instance"]
}
# Result: azuredatalakeprod001
```

### Key Vaults  
```hcl
azurerm_key_vault = {
  separator = "-"                   # Hyphens allowed
  component_order = ["prefix", "name", "environment", "region"]
}
# Result: azure-appsecrets-prod-westeurope
```

### Container App Environments
```hcl
azurerm_container_app_environment = {
  separator = "_"                   # Underscores for distinction
  component_order = ["prefix", "abbreviation", "name", "environment", "instance", "suffix"]
}
# Result: azure_cae_webapp_prod_001_v1
```

### Virtual Networks
```hcl
azurerm_virtual_network = {
  separator = "-"                   # Hyphens standard
  component_order = ["prefix", "abbreviation", "name", "environment", "region", "instance"]
}
# Result: azure-vnet-main-prod-westeurope-001
```

### Web Apps
```hcl
azurerm_linux_web_app = {
  separator = "-"                   # Clean, readable
  component_order = ["prefix", "abbreviation", "name", "environment", "suffix"]
}
# Result: azure-app-frontend-prod-v1
```

### SQL Databases
```hcl
azurerm_mssql_database = {
  separator = "-"                   # Standard hyphens
  component_order = ["prefix", "name", "environment", "instance", "suffix"]
}
# Result: azure-userdata-prod-001-v1
```

## Examples by Resource Type

| Resource Type | Example Name | Pattern Used | Reasoning |
|---------------|--------------|--------------|-----------|
| Storage Account | `azuredatalakeprod001` | No separators | Azure naming constraints |
| Key Vault | `azure-appsecrets-prod-westeurope` | Hyphens + region | Global uniqueness |
| Container App Env | `azure_cae_webapp_prod_001_v1` | Underscores + full | Service identification |
| Virtual Network | `azure-vnet-main-prod-westeurope-001` | Hyphens + region | Network topology |
| Web App | `azure-app-frontend-prod-v1` | Hyphens, no region | App simplicity |
| SQL Database | `azure-userdata-prod-001-v1` | Hyphens + instance | Data scaling |

## Pattern Design Principles

### 1. **Azure Constraints Compliance**
- Storage accounts: No separators, lowercase only
- Key vaults: Limited length, global uniqueness required
- Container apps: Flexible naming, service distinction helpful

### 2. **Operational Considerations**
- Include region for globally unique services
- Include instance numbers for scalable resources
- Exclude region for application-layer services

### 3. **Readability vs Constraints**
- Use hyphens where allowed for readability
- Use underscores for service distinction
- Omit separators only where required by Azure

### 4. **Component Selection**
- Essential components: prefix, name, environment
- Regional components: include for infrastructure
- Scaling components: instance numbers for databases/storage
- Version components: suffix for application versioning

## Testing Commands

```bash
# View all resource patterns
terraform plan -var-file="global_settings.tfvars" -var-file="resources.tfvars"

# Compare naming patterns by resource type
terraform output -json | jq -r '
  to_entries[] | 
  select(.value.naming_config) |
  "\(.key): \(.value.naming_config.final_name) (\(.value.naming_config.resource_type))"
'

# Show effective patterns
terraform output -json | jq '.*.value.naming_config.effective_naming'
```

## Benefits

- **🎯 Optimized**: Each resource type uses the best possible naming pattern
- **📏 Compliant**: Respects all Azure naming constraints and limitations
- **🔧 Flexible**: Different patterns for different operational needs
- **📊 Predictable**: Consistent patterns within each resource category
- **🛠️ Maintainable**: Clear reasoning behind each pattern choice

## Use Cases

1. **Multi-Service Applications**: Different naming for different service tiers
2. **Constraint Management**: Handling diverse Azure naming requirements
3. **Operational Excellence**: Optimized naming for different operational patterns
4. **Service Identification**: Clear distinction between different service types
