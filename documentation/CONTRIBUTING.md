# Contributing to terraform-azurerm-caf

> **Welcome! This guide will help you contribute to the Azure CAF Terraform Framework**

Thank you for your interest in contributing! This document provides guidelines and best practices for contributing to the terraform-azurerm-caf framework.

---

## 🎯 Quick Start for Contributors

### Prerequisites

- Terraform >= 1.9
- Azure CLI authenticated
- Git
- Basic understanding of:
  - Terraform
  - Azure services
  - Cloud Adoption Framework (CAF) principles

### Development Environment Setup

```bash
# Clone the repository
git clone https://github.com/aztfmod/terraform-azurerm-caf.git
cd terraform-azurerm-caf

# Create a new branch
git checkout -b feature/your-feature-name

# Install Terraform
# Download from: https://www.terraform.io/downloads

# Authenticate with Azure
az login
az account set --subscription <your-subscription-id>
```

---

## 📋 Contribution Checklist

Before submitting a pull request, ensure:

### Module Development
- [ ] Validated ALL resource attributes using MCP Terraform tools
- [ ] Followed standard module structure (providers.tf, variables.tf, outputs.tf, locals.tf, azurecaf_name.tf, service_name.tf)
- [ ] Implemented standard locals pattern (module_tag, tags, location, resource_group_name)
- [ ] Used CAF naming convention (no manual prefixes like "rg-", "st", etc.)
- [ ] Added diagnostics.tf if service supports diagnostic settings
- [ ] Added private_endpoints.tf if service supports private endpoints
- [ ] Used try() pattern for optional attributes
- [ ] Used coalesce() pattern for dependency resolution
- [ ] Implemented backward compatibility for renamed attributes

### Root Integration
- [ ] Created aggregator file `/category_service_names.tf`
- [ ] Added variable to `/variables.tf`
- [ ] Added to `/locals.tf`
- [ ] Added to `/locals.combined_objects.tf`
- [ ] Tested integration without errors

### Examples
- [ ] Created numbered examples (100-simple, 200-intermediate, etc.)
- [ ] Used `configuration.tfvars` as filename (not minimal/complete/example)
- [ ] Removed resource type prefixes from names (e.g., no "rg-", "st", "kv-")
- [ ] Used key-based references (`resource_group = { key = "rg_key" }`)
- [ ] Included global_settings with random_length
- [ ] Added example to appropriate `.github/workflows/*.json` file
- [ ] Tested examples locally with `terraform test`

### Documentation
- [ ] Updated module README.md
- [ ] Added module to docs/modules/CATALOG.md (if new category)
- [ ] Updated CHANGELOG.md
- [ ] All content in English

### Testing
- [ ] Tested locally with terraform test
- [ ] No errors in terraform plan
- [ ] No hardcoded subscription IDs or resource IDs
- [ ] Validated against existing examples

---

## 🏗️ Creating a New Module

### Step-by-Step Guide

#### 1. Research the Azure Resource

Before creating a module, use MCP Terraform tools to validate ALL resource attributes:

```bash
# 1. Resolve provider documentation ID
mcp_terraform_resolveProviderDocID(
  providerName="azurerm",
  providerNamespace="hashicorp",
  serviceSlug="dashboard_grafana",  # Your resource name
  providerDataType="resources"
)

# 2. Get complete resource schema
mcp_terraform_getProviderDocs(providerDocID="<ID_from_step_1>")

# 3. Implement ALL attributes from the schema
```

**This validation is MANDATORY for every resource.**

#### 2. Create Module Directory Structure

```bash
# Create module directory
mkdir -p modules/category/service_name

# Create standard files
touch modules/category/service_name/providers.tf
touch modules/category/service_name/variables.tf
touch modules/category/service_name/outputs.tf
touch modules/category/service_name/locals.tf
touch modules/category/service_name/azurecaf_name.tf
touch modules/category/service_name/service_name.tf
touch modules/category/service_name/diagnostics.tf
touch modules/category/service_name/private_endpoints.tf
```

#### 3. Implement Standard Files

**providers.tf**:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 2.0"
    }
  }
}
```

**variables.tf**: Copy standard variables (see Architecture doc)

**locals.tf**: MUST follow standard pattern:
```hcl
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
  ) : merge(
    local.module_tag,
    try(var.settings.tags, null)
  )
  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group_name, var.resource_group.name)
}
```

**azurecaf_name.tf**:
```hcl
resource "azurecaf_name" "service_name" {
  name          = var.settings.name
  resource_type = "azurerm_service_name"  # Match actual Azure resource type
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
```

**service_name.tf**: Implement ALL resource attributes from MCP Terraform schema:
```hcl
resource "azurerm_service_name" "service" {
  name                = azurecaf_name.service_name.result
  resource_group_name = local.resource_group_name
  location            = local.location
  
  # Required attributes
  required_attr = var.settings.required_attr
  
  # Optional attributes with try()
  optional_attr1 = try(var.settings.optional_attr1, null)
  optional_attr2 = try(var.settings.optional_attr2, default_value)
  
  # Dynamic blocks
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }
  
  tags = merge(local.tags, try(var.settings.tags, null))
}
```

**diagnostics.tf** (if service supports it):
```hcl
module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_service_name.service.id
  resource_location = azurerm_service_name.service.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

**private_endpoints.tf** (if service supports it):
```hcl
module "private_endpoint" {
  source   = "../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id         = azurerm_service_name.service.id
  name                = each.value.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = can(each.value.subnet_id) || can(each.value.virtual_subnet_key) ? try(each.value.subnet_id, var.virtual_subnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.virtual_subnet_key].id) : var.vnets[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.vnet_key].subnets[each.value.subnet_key].id
  settings            = each.value
  global_settings     = var.global_settings
  tags                = local.tags
  base_tags           = var.base_tags
  private_dns         = var.private_dns
  client_config       = var.client_config
}
```

**outputs.tf**:
```hcl
output "id" {
  value       = azurerm_service_name.service.id
  description = "The ID of the service"
}

output "name" {
  value       = azurecaf_name.service_name.result
  description = "The name of the service"
}

# Add all useful outputs
```

#### 4. Integrate with Root Module

**Create `/category_service_names.tf`**:
```hcl
module "service_names" {
  source   = "./modules/category/service_name"
  for_each = local.category.service_names

  global_settings     = local.global_settings
  client_config       = local.client_config
  location            = try(each.value.location, null)
  base_tags           = local.global_settings.inherit_tags
  resource_group      = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name
  settings            = each.value
  private_endpoints   = try(each.value.private_endpoints, {})

  remote_objects = {
    resource_groups = local.combined_objects_resource_groups
    diagnostics     = local.combined_diagnostics
    vnets           = local.combined_objects_networking
    virtual_subnets = local.combined_objects_virtual_subnets
    private_dns     = local.combined_objects_private_dns
  }
}

output "service_names" {
  value = module.service_names
}
```

**Add to `/variables.tf`**:
```hcl
variable "category" {
  description = "Configuration for category services"
  default     = {}
}
```

**Add to `/locals.tf`**:
```hcl
locals {
  category = {
    service_names = try(var.category.service_names, {})
  }
}
```

**Add to `/locals.combined_objects.tf`**:
```hcl
combined_objects_service_names = merge(
  tomap({ (local.client_config.landingzone_key) = module.service_names }),
  lookup(var.remote_objects, "service_names", {}),
  lookup(var.data_sources, "service_names", {})
)
```

#### 5. Create Examples

**Create directory structure**:
```bash
mkdir -p examples/category/service_name/100-simple-service
mkdir -p examples/category/service_name/200-service-private-endpoint
```

**Create `100-simple-service/configuration.tfvars`**:
```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  service_rg = {
    name = "service-test-1"  # NO "rg-" prefix!
  }
}

category = {
  service_names = {
    instance1 = {
      name = "service-instance-1"
      resource_group = {
        key = "service_rg"
      }
      # Minimal required configuration
      required_setting = "value"
      
      tags = {
        environment = "dev"
        purpose     = "example"
      }
    }
  }
}
```

**Create `200-service-private-endpoint/configuration.tfvars`**:
Include full networking stack (vnets, virtual_subnets, NSG, private DNS, private endpoints).

#### 6. Add to CI/CD Workflow

Edit the appropriate `.github/workflows/*.json` file:

```json
{
  "config_files": [
    "existing/examples",
    "category/service_name/100-simple-service",
    "more/examples"
  ]
}
```

#### 7. Test Locally

```bash
cd examples
terraform test -test-directory=./tests/mock \
  -var-file="./category/service_name/100-simple-service/configuration.tfvars" \
  -verbose
```

#### 8. Create Module README.md

```markdown
# Azure [Service Name] Module

## Overview
Brief description of the Azure service and module purpose.

## Features
- ✅ CAF Naming Convention
- ✅ Diagnostic Settings Integration
- ✅ Private Endpoint Support

## Usage

### Simple Example
\`\`\`hcl
[Include content from 100-simple example]
\`\`\`

### Advanced Example
\`\`\`hcl
[Include content from 200+ examples]
\`\`\`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
[Auto-generated from variables.tf]

## Outputs

| Name | Description |
|------|-------------|
[Auto-generated from outputs.tf]

## Examples

See the [examples directory](../../examples/[category]/[service]) for complete working examples.
```

---

## 🔧 Updating an Existing Module

### Process

1. **Check for provider updates**:
   - Visit: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/[resource]
   - Use MCP Terraform tools to validate ALL attributes
   - Compare with current implementation
   - Note: New arguments, deprecated features, changed defaults

2. **Review examples for backward compatibility**:
   ```bash
   find examples -name "*.tfvars" -path "*category/service*" | head -5
   ```

3. **Implement changes**:
   - Add new arguments with try() for optional features
   - Maintain deprecated arguments for backward compatibility using try() fallbacks:
     ```hcl
     # Support both new and old attribute names
     enabled_attribute = try(
       var.settings.enabled_attribute,  # New name (preferred)
       var.settings.attribute_enabled,  # Old name (backward compatibility)
       true                              # Default value
     )
     ```
   - Update dynamic blocks if new nested blocks added

4. **Update examples**:
   - Add new features to complete example (200+ level)
   - Create migration guide if breaking changes

5. **Test thoroughly**:
   ```bash
   cd examples
   terraform test -test-directory=./tests/mock \
     -var-file="./category/service/200-complete/configuration.tfvars" \
     -verbose
   ```

---

## 📝 Code Style and Standards

### Naming Conventions

#### Module Names
- Use Azure resource name without provider prefix: `container_app` (not `azurerm_container_app`)
- Use plural for aggregators: `container_apps` (not `container_app`)
- Use snake_case for directories and files

#### Variable Names
- **DON'T** include resource type prefixes in example names:
  ```hcl
  # ❌ WRONG
  resource_groups = {
    rg1 = {
      name = "rg-grafana-test-1"  # "rg-" will be duplicated
    }
  }
  
  # ✅ CORRECT
  resource_groups = {
    rg1 = {
      name = "grafana-test-1"  # azurecaf adds "rg-"
    }
  }
  ```

### Terraform Code Style

#### Attribute Patterns

**For optional attributes**:
```hcl
# Without default value
optional_attr = try(var.settings.optional_attr, null)

# With default value
optional_attr = try(var.settings.optional_attr, default_value)
```

**For backward compatibility**:
```hcl
# Support old and new attribute names
attribute = try(
  var.settings.new_name,    # New name
  var.settings.old_name,    # Old name
  default_value             # Default
)
```

**For required attributes**:
```hcl
required_attr = var.settings.required_attr
```

**For tags** (always use this pattern):
```hcl
tags = merge(local.tags, try(var.settings.tags, null))
```

**For resource group**:
```hcl
resource_group_name = local.resource_group_name
```

**For location**:
```hcl
location = local.location
```

#### Dynamic Blocks

**Optional single block (0 or 1)**:
```hcl
dynamic "identity" {
  for_each = var.settings.identity == null ? [] : [var.settings.identity]
  content {
    type         = identity.value.type
    identity_ids = try(identity.value.identity_ids, null)
  }
}
```

**Multiple blocks from list**:
```hcl
dynamic "rule" {
  for_each = try(var.settings.rules, [])
  content {
    name     = rule.value.name
    priority = rule.value.priority
  }
}
```

**Multiple blocks from map**:
```hcl
dynamic "rule" {
  for_each = try(var.settings.rules, {})
  content {
    name     = rule.key  # Map key as identifier
    action   = rule.value.action
    priority = rule.value.priority
  }
}
```

#### Dependency Resolution

**Use coalesce pattern**:
```hcl
resource_id = coalesce(
  try(var.settings.direct_id, null),
  try(var.remote_objects.resource_name.id, null),
  try(var.remote_objects.resources[
    try(var.settings.ref.lz_key, var.client_config.landingzone_key)
  ][var.settings.ref.key].id, null)
)
```

### Documentation Style

- **Language**: All documentation MUST be in English
- **Comments**: Use inline comments only when logic is complex
- **README**: Keep concise, focus on usage
- **Examples**: Self-explanatory with realistic configurations

---

## 🧪 Testing Guidelines

### Local Testing

```bash
# Test specific example
cd examples
terraform test -test-directory=./tests/mock \
  -var-file="./category/service/100-simple/configuration.tfvars" \
  -verbose

# Test all examples in category
terraform test -test-directory=./tests/mock \
  -var-file="./category/**/configuration.tfvars" \
  -verbose
```

### Common Test Failures

| Error | Cause | Solution |
|-------|-------|----------|
| "Unknown variable" | Variable not in examples/variables.tf | Check variable name matches root variables.tf |
| "Invalid reference" | Using wrong key format | Use `resource_group = { key = "rg_key" }` |
| "Resource name too long" | Included azurecaf prefix in name | Remove prefix, let azurecaf add it |
| "Network config invalid" | Using wrong variable names | Use `vnets` and `virtual_subnets` |

---

## 📬 Pull Request Process

### Before Submitting

1. **Complete the checklist** at the top of this document
2. **Test locally** with terraform test
3. **Update CHANGELOG.md** with your changes
4. **Ensure all content is in English**

### PR Title Format

```
[category] Description of change

Examples:
[cognitive_services] Add AI Services module
[networking] Fix private endpoint subnet resolution
[docs] Update architecture documentation
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New module
- [ ] Module update
- [ ] Bug fix
- [ ] Documentation update
- [ ] Example update

## Checklist
- [ ] Validated attributes with MCP Terraform
- [ ] Followed standard module structure
- [ ] Added/updated examples
- [ ] Added to workflow JSON
- [ ] Tested locally
- [ ] Updated documentation
- [ ] All content in English

## Testing
Describe how you tested the changes

## Related Issues
Closes #issue_number
```

### Review Process

1. **Automated checks**: Workflow validation, syntax checks
2. **Code review**: Maintainer review for standards compliance
3. **Testing**: Automated tests run on PR
4. **Approval**: At least one maintainer approval required
5. **Merge**: Squash and merge to main branch

---

## 🐛 Reporting Issues

### Bug Reports

Use the issue template:

```markdown
**Describe the bug**
A clear and concise description

**To Reproduce**
Steps to reproduce:
1. Use module '...'
2. With configuration '...'
3. See error

**Expected behavior**
What you expected to happen

**Environment**
- Terraform version:
- Azure provider version:
- Module version:

**Additional context**
Any other relevant information
```

### Feature Requests

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
What you want to happen

**Describe alternatives you've considered**
Alternative solutions

**Additional context**
Any other relevant information
```

---

## 💡 Best Practices

### Do's ✅

- **DO** use MCP Terraform tools to validate ALL resource attributes
- **DO** follow the standard module structure exactly
- **DO** use try() for optional attributes
- **DO** use coalesce() for dependency resolution
- **DO** let azurecaf add resource type prefixes automatically
- **DO** create numbered examples (100-, 200-, 300-)
- **DO** use `configuration.tfvars` as example filename
- **DO** test locally before submitting PR
- **DO** maintain backward compatibility when possible
- **DO** write all content in English

### Don'ts ❌

- **DON'T** include resource type prefixes in names (no "rg-", "st", "kv-")
- **DON'T** create azurerm_private_endpoint directly in service modules
- **DON'T** hardcode subscription IDs or resource IDs
- **DON'T** use `minimal.tfvars` or `complete.tfvars` as filenames
- **DON'T** skip MCP Terraform validation
- **DON'T** forget to add examples to workflow JSON
- **DON'T** break backward compatibility without documentation
- **DON'T** write documentation in languages other than English

---

## 📚 Additional Resources

- [Architecture Overview](../architecture/OVERVIEW.md)
- [Module Catalog](../modules/CATALOG.md)
- [Examples Index](../examples/INDEX.md)
- [Copilot Instructions](../../.github/copilot-instructions.md) - Comprehensive AI coding guide
- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AzureCAF Provider](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs)

---

## 🤝 Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](../../CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## 📞 Getting Help

- **GitHub Discussions**: Ask questions and share ideas
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check the docs folder first
- **Examples**: Look at working examples in /examples

---

**Thank you for contributing to terraform-azurerm-caf! 🙏**

---

**Last Updated**: 2024
**Contribution Guide Version**: 1.0
