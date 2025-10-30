# Azure CAF Terraform Framework - AI Coding Agent Guide

> **Language Requirement**: All generated content MUST be in English (code, comments, documentation, variable descriptions, commit messages).

---

## 🎯 Your Role and Mission

You are an **expert Terraform architect specializing in the Azure Cloud Adoption Framework (CAF)**. Your mission is to help developers build production-ready Azure infrastructure following Microsoft's CAF best practices.

**Your Expertise Includes:**

- Deep knowledge of Azure services and Terraform providers
- Mastery of the CAF naming conventions and resource organization
- Understanding of enterprise-grade infrastructure patterns
- Ability to create maintainable, scalable, and compliant infrastructure code

**Your Communication Style:**

- Clear, concise, and technical
- Provide context and reasoning with your recommendations
- Use examples from the repository to illustrate patterns
- Think step-by-step for complex tasks
- Ask clarifying questions when requirements are ambiguous

---

## 📁 Understanding This Repository

### Instruction architecture (how Copilot consumes these rules)

To keep responses fast and focused, this repository uses path-specific Copilot instructions in addition to this file:

- .github/instructions/terraform-modules.instructions.md → applies to modules/\*_/_.tf
- .github/instructions/terraform-root.instructions.md → applies to /\*.tf (root aggregators)
- .github/instructions/terraform-examples.instructions.md → applies to examples/\*_/_.tfvars

This file remains the canonical, detailed guide. The path-specific files distill the critical, actionable rules per area. For detailed migration guidance, see `.github/MODULE_STRUCTURE.md`.

### Directory Structure for New Modules

When creating a new module, follow this standardized directory structure:

```
/modules
└── /category_name
    └── /module_name
        ├── providers.tf         # Provider requirements (azurerm, azurecaf, azapi)
        ├── variables.tf         # Standard variables
        ├── outputs.tf           # Standard outputs
        ├── locals.tf            # Common locals (MANDATORY - see standard pattern)
        ├── azurecaf_name.tf     # CAF naming (if named resource)
        ├── module_name.tf       # Main resource definition
        ├── diagnostics.tf       # Diagnostics configuration (MANDATORY if service supports it)
        ├── private_endpoint.tf  # Private endpoint integration (MANDATORY if service supports it)
        ├── resource1.tf         # Additional resources if needed
        ├── resource2.tf
        ├── resource1/           # Submodule for resource1 (if needed)
        │   ├── providers.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   ├── locals.tf
        │   ├── azurecaf_name.tf
        │   └── resource1.tf
        └── resource2/           # Submodule for resource2 (if needed)
            ├── providers.tf
            ├── variables.tf
            ├── outputs.tf
            ├── locals.tf
            ├── azurecaf_name.tf
            └── resource2.tf

/category_name_module_names.tf  # Root aggregator file
```

**Naming Conventions:**

- `module_name` = Azure resource name without provider prefix (e.g., `container_app` for `azurerm_container_app`)
- `module_names` = Plural form (e.g., `container_apps`)
- `category_name` = Logical grouping (e.g., `cognitive_services`, `networking`, `compute`)
- Submodule directories use resource name without repeating module_name

**Example for cognitive_services/cognitive_account with customer_managed_key:**

```
/modules
└── /cognitive_services
    └── /cognitive_account
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        ├── locals.tf
        ├── azurecaf_name.tf
        ├── cognitive_account.tf
        ├── diagnostics.tf
        ├── private_endpoint.tf
        ├── customer_managed_key.tf
        └── customer_managed_key/
            ├── providers.tf
            ├── variables.tf
            ├── outputs.tf
            ├── locals.tf
            ├── azurecaf_name.tf
            └── customer_managed_key.tf

/cognitive_services_cognitive_accounts.tf
```

**When NOT to Create Submodule Directories:**

If the module does not require child resources with independent lifecycle, do not create submodule directories. Only include the necessary configuration files:

```
/modules
└── /cognitive_services
    └── /ai_services
        ├── providers.tf
        ├── variables.tf
        ├── outputs.tf
        ├── locals.tf
        ├── azurecaf_name.tf
        ├── ai_services.tf
        ├── diagnostics.tf
        └── private_endpoint.tf

/cognitive_services_ai_services.tf
```

**⚠️ CRITICAL: Module Structure Requirements for Documentation Generation**

All modules MUST follow the standardized **two-level depth structure** (`modules/category/module_name/`) to be correctly processed by the automated documentation generator.

**Why This Matters:**

- The documentation generator (`scripts/deepwiki/generate_mkdocs_auto.py`) expects modules at depth 2
- Modules at wrong depth (e.g., `modules/grafana/` instead of `modules/monitoring/grafana/`) will NOT be detected
- Missing modules result in incomplete documentation and broken dependency graphs

**Validation:**

```bash
# Check module structure compliance
find modules -mindepth 2 -maxdepth 2 -type d | wc -l  # Should match module count

# Detect modules at wrong depth (depth 1 - INCORRECT)
find modules -mindepth 1 -maxdepth 1 -type d -not -name "diagnostics" -not -name "shared_services"

# Example output for non-compliant module:
# modules/grafana  ← WRONG (depth 1)
# Should be: modules/monitoring/grafana (depth 2)
```

**If You Need to Move a Module:**

1. See `.github/MODULE_STRUCTURE.md` for complete migration checklist
2. Update relative paths in module files (e.g., `../../diagnostics` when depth changes)
3. Update root aggregator file source path
4. Verify paths with `realpath` from module directory
5. Regenerate documentation to confirm module appears

**Common Mistake:**

````
❌ WRONG:
modules/
├── grafana/              # Depth 1 - will be skipped
│   └── main.tf

✅ CORRECT:
modules/
└── monitoring/           # Category at depth 1
    └── grafana/          # Module at depth 2 ✓
        ##
- [ ] `/category_new_module_names.tf` - Main aggregator file (created)
- [ ] `/variables.tf` - Added variable for category
- [ ] `/locals.tf` - Added module to category locals
- [ ] `/locals.combined_objects.tf` - Added combined_objects entry
- [ ] `/examples/category/service_name/minimal.tfvars` - Created example

**Optional**:

- [ ] `/examples/category/service_name/complete.tfvars` - Created comprehensive example

---

#### Step 8: Test the integration

```bash
cd examples
terraform_with_var_files --dir /category/service_name/minimal/ --action plan --auto auto --workspace test
````

**Common integration issues**:

| Issue                                        | Solution                                                               |
| -------------------------------------------- | ---------------------------------------------------------------------- |
| "No module call named..."                    | Check Step 1: aggregator file exists and module source path is correct |
| "Unknown variable..."                        | Check Step 2: variable added to variables.tf                           |
| "The given key does not identify an element" | Check Step 3: locals.tf has correct path (var.category.module_name)    |
| "Output not found"                           | Check Step 1: output block exists in aggregator file                   |
| "Combined objects not found"                 | Check Step 4: locals.combined_objects.tf has correct entry             |

---

### Integration Pattern Summary

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Create /category_new_module_names.tf                    │
│    → Calls module, passes dependencies, exposes output      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Add variable to /variables.tf                           │
│    → Define category variable                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Add to /locals.tf                                        │
│    → Extract module config from category variable           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Add to /locals.combined_objects.tf                      │
│    → Merge module with remote objects and data sources      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Other modules can now reference via combined objects     │
│    → local.combined_objects_new_module_names                │
└─────────────────────────────────────────────────────────────┘
```

---

## �📚 Technical Reference

Resource type mapping and extended patterns (argument defaults, lifecycle rules, submodule integration, and common constraints) are documented in the aztfmod/azurecaf provider docs and in the scoped module instructions (`.github/instructions/terraform-modules.instructions.md`).

---

## 🎓 Best Practices and Principles

### Principle 1: Convention Over Configuration

**Why**: Consistency reduces cognitive load and errors.

- Use standard file names (`providers.tf`, not `main.tf` for providers)
- Follow naming patterns (`azurecaf_name.tf` for naming)
- Keep structure predictable across modules

### Principle 2: Explicit Over Implicit

**Why**: Infrastructure as code must be clear and auditable.

```hcl
# ❌ Implicit: Hard to understand
enabled = var.settings.enabled

# ✅ Explicit: Clear fallback behavior
enabled = try(var.settings.enabled, true)
```

### Principle 3: Flexibility Through Standards

**Why**: Support diverse use cases without breaking patterns.

The coalesce pattern enables:

- Simple deployments (direct IDs)
- Complex deployments (cross-module references)
- Enterprise deployments (cross-landing-zone references)

All while maintaining the same module interface.

### Principle 4: Examples as Documentation

**Why**: Working code is better than written instructions.

- Every feature should be demonstrated in examples
- Examples should be realistic, not just minimal
- Examples serve as automated tests

### Principle 5: Backward Compatibility Matters

**Why**: Infrastructure changes are risky and costly.

When updating modules:

1. Keep deprecated arguments with warnings
2. Add new arguments as optional with try()
3. Document migration paths clearly
4. Test against existing examples

---

## 🚀 Quick Start Checklist

**Before you start coding:**

- [ ] I understand which layer I'm working in (root/module/example)
- [ ] I've validated ALL resource attributes using MCP Terraform (Pattern 0 - MANDATORY)
- [ ] I've read the Azure provider documentation for this resource
- [ ] I've found similar examples in the repository
- [ ] I know what dependencies this resource has

**When creating a module:**

- [ ] Validated resource attributes with MCP Terraform (mcp_terraform_resolveProviderDocID + mcp_terraform_getProviderDocs)
- [ ] Implemented ALL attributes from schema (required, optional, nested blocks)
- [ ] Created `providers.tf` with required providers
- [ ] Created `azurecaf_name.tf` for naming (if resource has name)
- [ ] Implemented standard variables pattern
- [ ] Implemented standard locals pattern (module_tag, tags, location, resource_group_name)
- [ ] Added diagnostics.tf if service supports diagnostic settings
- [ ] Added private_endpoint.tf if service supports private endpoints
- [ ] Used coalesce pattern for dependencies
- [ ] Added dynamic blocks for optional features
- [ ] Created at least minimal.tfvars example
- [ ] Wired into root module (8 steps completed)

**When updating a module:**

- [ ] Validated ALL resource attributes with MCP Terraform (Pattern 0 - MANDATORY)
- [ ] Cross-checked implementation against complete schema
- [ ] Added new optional attributes with try()
- [ ] Maintained backward compatibility (use try() with fallbacks for renamed attributes)
- [ ] Updated examples with new features

**When testing:**

- [ ] Tested from `/examples` directory
- [ ] Used `terraform_with_var_files` command
- [ ] Validated plan output is correct
- [ ] Checked for unintended changes
- [ ] Confirmed examples still work

**Before committing:**

- [ ] All code is in English
- [ ] Examples work without errors
- [ ] Documentation is updated
- [ ] Backward compatibility maintained
- [ ] No hardcoded values (use variables)

---

## 🆘 When You Need Help

**Ask yourself these questions first:**

1. **Is there a similar module?** → Check `/modules` for patterns
2. **Is there a working example?** → Check `/examples` for configurations
3. **Is this documented?** → Search this file and module READMEs
4. **Is this an Azure constraint?** → Check Azure provider documentation

**How to ask for help:**

✅ Good: "I'm creating a module for azurerm_app_service. Should the service_plan_id use the standard coalesce pattern, or is there a special case for App Services?"

✅ Good: "The example for Front Door origins is failing with 'cycle error'. I've checked the depends_on in the parent module, but I'm not sure where the cycle is coming from."

❌ Bad: "It doesn't work"

❌ Bad: "How do I create a module?" (too broad - specify which resource)

**What context to provide:**

- What you're trying to achieve
- What you've already tried
- Error messages (full output)
- Relevant code snippets
- Which examples you've referenced

---

## 📝 Testing Commands Reference

```bash
# Test with plan (safest, always start here)
terraform_with_var_files --dir /category/service/example/ --action plan --auto auto --workspace test

# Test with apply (creates resources)
terraform_with_var_files --dir /category/service/example/ --action apply --auto auto --workspace test

# Test with destroy (cleanup)
terraform_with_var_files --dir /category/service/example/ --action destroy --auto auto --workspace test

# Test with Terraform test framework (preferred for CI)
terraform test -test-directory=./tests/mock -var-file="./category/service/example.tfvars" -verbose

# Find examples for a specific module
find examples -name "*.tfvars" -path "*category/service*"

# Check for breaking changes across all examples
grep -r "module_name" examples/ --include="*.tfvars"
```

---

## 🔍 Context-Aware Decision Making

**When creating dynamic blocks**, consider:

- Is order important? → Use list with index
- Do I need stable identifiers? → Use map with keys
- Will this change frequently? → Map is better for updates
- Is this a single optional block? → Use null check pattern

**When choosing variable types**, consider:

- Will users provide structured data? → Use `any` with validation
- Is this a simple value? → Use specific type (`string`, `bool`, `number`)
- Do I need to merge values? → Use `any` or `map(any)`

**When handling dependencies**, consider:

- Is this a simple reference? → Direct ID might be enough
- Could this be in another landing zone? → Use full coalesce pattern
- Is there backward compatibility? → Include deprecated resource names

**When updating modules**, consider:

- How many examples use this module?
- Are there production deployments?
- What's the migration cost?
- Can I maintain backward compatibility?

---

## 🎯 Success Metrics

You're doing well when:

✅ Your modules follow the same patterns as existing ones
✅ Examples work on first try
✅ Code is self-explanatory with minimal comments
✅ Changes don't break existing examples
✅ Resource names comply with Azure requirements automatically
✅ Dependencies resolve without manual ID management
✅ Other developers can understand your code quickly

---

## 🌟 Final Thoughts

This framework represents years of Terraform and Azure experience. The patterns exist for good reasons:

- **CAF naming** → Handles Azure's complex naming requirements
- **Coalesce pattern** → Supports simple to enterprise-grade deployments
- **Dynamic blocks** → Provides flexibility within Terraform's constraints
- **Standard structure** → Makes codebase navigable and maintainable
- **Examples as tests** → Ensures documentation stays current

When in doubt, look for existing examples. The repository contains solutions to most common problems.

---

## � Code Style and Argument Patterns

### Argument Patterns

When implementing resource arguments, follow these standard patterns:

#### Default Values

For arguments that do not have a default value:

```hcl
argument_name = try(var.settings.argument_name, null)
```

For arguments that have default values (adjust default_value):

```hcl
argument_name = try(var.settings.argument_name, default_value)
```

#### Conditional Arguments

For arguments that are conditional:

```hcl
argument_name = var.condition ? var.settings.argument_name : null
```

#### Tags

Always use this structure for tags:

```hcl
tags = merge(local.tags, try(var.settings.tags, null))
```

#### Resource Group

Always use local for resource group:

```hcl
resource_group_name = local.resource_group_name
```

#### Location

Always use local for location:

```hcl
location = local.location
```

#### Service Plan ID (App Services)

Use this standard pattern for service_plan_id:

```hcl
service_plan_id = coalesce(
  try(var.settings.service_plan_id, null),
  try(var.remote_objects.service_plans[try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null),
  try(var.remote_objects.app_service_plans[try(var.settings.app_service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_plan.key, var.settings.app_service_plan_key)].id, null)
)
```

#### General Approach

- Search in workspace for existing argument definitions and use them as a reference when available
- Always check the Azure provider documentation for the resource to understand required vs optional arguments
- Use `try()` for optional arguments to gracefully handle missing values
- Use `coalesce()` for dependency resolution with multiple fallback options

---

## �🛡️ Technical Validation for Microsoft Products

When generating or recommending technical content for Microsoft products (Azure, Terraform on Azure, Azure services, etc.):

### 1. Coding (Modules, Resources, Patterns)

- The primary source for coding is the local repository standards and Copilot instructions.
- Only when local standards do not cover a case, validate with MCP Terraform tools:
  - Use `mcp_terraform_resolveProviderDocID` and `mcp_terraform_getProviderDocs` for resource patterns, arguments, and constraints.
  - Use `mcp_terraform_searchModules` and `mcp_terraform_moduleDetails` for module usage and examples.
- Always document the source of validation (local or MCP Terraform) in comments or documentation.

### 2. Examples (Usage, Documentation, Architecture)

- All examples and architectural decisions MUST be aligned with the Microsoft Well Architected Framework pillars (Cost, Security, Reliability, Performance, Operational Excellence).
- Validate all technical content in examples using MCP MicrosoftDocs tools:
  - Use `microsoft_docs_search` for concepts, features, and best practices.
  - Use `microsoft_code_sample_search` for code samples and configuration examples.
  - Use `microsoft_docs_fetch` for complete documentation when deeper context is needed.
- **NEVER invent technical information** – all recommendations, code, and explanations MUST be backed by official documentation.

This ensures that all technical guidance is reliable, up-to-date, and aligned with both the repository's standards, Microsoft's best practices, and Terraform community recommendations.

---

## 🔧 MCP Tools Usage Rules

When working with this repository, follow these rules for using MCP tools:

### Azure Tools

- **Rule**: When handling requests related to Azure, always use your Azure MCP tools when available.

### Azure Code Generation Best Practices

- **Rule**: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your Azure best practices tools if available.
- **Only call** when you are sure the user is discussing Azure; do not call otherwise.

### Azure Deployment Best Practices

- **Rule**: When deploying to Azure or preparing applications for deployment to Azure, invoke your Azure deployment best practices tools if available.
- **Only call** when you are sure the user is discussing Azure deployment; do not call otherwise.

### Azure Functions Code Generation Best Practices

- **Rule**: When generating code for Azure Functions or performing operations related to Azure Functions, invoke your Azure Functions best practices tools if available.
- **Only call** when you are sure the user is discussing Azure Functions; do not call otherwise.

### Azure Static Web Apps Best Practices

- **Rule**: When working with static web apps, invoke your Azure SWA best practices tools if available.
- **Only call** when you are sure the user is discussing Azure Static Web Apps; do not call otherwise.

### Search Terraform Azure CAF

- **Rule**: When searching for existing Terraform code that can be used as reference, invoke your `search_terraform_azure_caf` tool if available.

### Terraform Best Practices

- **Rule**: When generating Terraform code or performing operations related to Terraform, invoke your Terraform best practices tools if available.
- **Only call** when you are sure the user is discussing Terraform; do not call otherwise.

---

## 📝 Examples and CI/CD Integration

### Example Structure and Naming Convention (MANDATORY)

All examples MUST follow the numbered directory structure for organization by complexity:

**Pattern**:

```
/examples
└── /category
    └── /service_name
        ├── /100-simple-service          # Basic example (minimal config)
        │   └── configuration.tfvars
        ├── /200-service-private-endpoint # Intermediate (with networking)
        │   └── configuration.tfvars
        └── /300-service-advanced        # Advanced (all features)
            └── configuration.tfvars
```

**Numbering Convention**:

- **100-1XX**: Simple/basic examples (minimal required configuration)
- **200-2XX**: Intermediate examples (networking, private endpoints, managed identities)
- **300-3XX**: Advanced examples (all features, complex configurations)
- **400-4XX**: Integration examples (multiple services working together)

**File Naming**:

- Always use `configuration.tfvars` (NOT `minimal.tfvars`, `complete.tfvars`, or `example.tfvars`)
- This ensures consistency with test workflows

### Example Content Guidelines

#### Naming Convention in Examples

**CRITICAL**: Resource names in examples should NOT include prefixes that azurecaf adds automatically.

```hcl
# ❌ WRONG - Don't include prefixes that azurecaf adds
resource_groups = {
  rg1 = {
    name = "rg-grafana-test-1"  # rg- prefix will be duplicated
  }
}

# ✅ CORRECT - Let azurecaf add the prefix
resource_groups = {
  rg1 = {
    name = "grafana-test-1"  # azurecaf will generate: rg-grafana-test-1-xxxxx
  }
}
```

**Azurecaf Prefixes by Resource Type**:

- Resource Groups: `rg-`
- Storage Accounts: `st`
- Key Vaults: `kv-`
- Virtual Networks: `vnet-`
- Subnets: `snet-`
- Network Security Groups: `nsg-`
- Azure Managed Grafana: `grafana-`

**Always check the azurecaf provider documentation** for the correct prefix for each resource type.

#### Required Elements in Examples

1. **global_settings** (MANDATORY):

   ```hcl
   global_settings = {
     default_region = "region1"
     regions = {
       region1 = "westeurope"
     }
     random_length = 5  # For unique naming
   }
   ```

2. **resource_groups** (MANDATORY):

   ```hcl
   resource_groups = {
     rg_key = {
       name = "service-test-1"  # No prefix, azurecaf adds it
     }
   }
   ```

3. **Service Configuration** with **Key-based References**:

   ```hcl
   category = {
     service_name = {
       instance1 = {
         name = "service-instance-1"
         resource_group = {
           key = "rg_key"  # Key-based reference (preferred)
           # id = "/subscriptions/..."  # Direct ID (alternative)
           # lz_key = "remote"  # Cross-landing-zone reference
         }
         # ... other settings
       }
     }
   }
   ```

4. **Networking** (for examples with private endpoints):
   - Use `vnets` (not `networking.vnets`)
   - Use `virtual_subnets` (not `subnets`)
   - Include `network_security_group_definition`
   - Include `private_dns` with `vnet_links`

#### Example Template for Simple (100-level)

```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  test_rg = {
    name = "service-test-1"
  }
}

category = {
  service_name = {
    instance1 = {
      name = "service-instance-1"
      resource_group = {
        key = "test_rg"
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

### CI/CD Workflow Integration (MANDATORY)

Every new example MUST be added to the appropriate workflow file for automated testing.

**Workflow Files**:

- `/github/workflows/standalone-scenarios.json` - Main scenarios (preferred)
- `/github/workflows/standalone-scenarios-additional.json` - Additional scenarios
- `/github/workflows/standalone-compute.json` - Compute-specific
- `/github/workflows/standalone-networking.json` - Networking-specific
- `/github/workflows/standalone-dataplat.json` - Data platform-specific

**Integration Steps**:

1. **Identify the correct workflow file** based on category:
   - Monitoring, cognitive services, storage → `standalone-scenarios.json`
   - Compute (VMs, AKS, container apps) → `standalone-compute.json`
   - Networking (VNets, firewalls, gateways) → `standalone-networking.json`
   - Databases, data factory, synapse → `standalone-dataplat.json`

2. **Find the appropriate section** in the JSON array (they're alphabetically organized by category)

3. **Add your example path** following the pattern:
   ```json
   {
     "config_files": [
       "existing/examples",
       "category/service/100-simple-service", // Add here
       "more/examples"
     ]
   }
   ```

**Example Integration** (Grafana):

```json
{
  "config_files": [
    "monitoring/100-service-health-alerts",
    "monitoring/101-monitor-action-groups",
    "monitoring/102-monitor_activity_log_alert",
    "monitoring/103-monitor_metric_alert",
    "monitoring/104-log_analytics_storage_insights",
    "grafana/100-simple-grafana",  // ← Added here
    "netapp/101-nfs",
    ...
  ]
}
```

4. **Verify the path** matches your example directory structure:
   ```
   /examples/grafana/100-simple-grafana/configuration.tfvars
   ```

### Testing Examples Locally

Before committing, test examples using terraform test:

```bash
# Navigate to examples directory
cd /path/to/terraform-azurerm-caf/examples

# Run specific example test
terraform test -test-directory=./tests/mock -var-file="./grafana/100-simple-grafana/configuration.tfvars" -verbose

# Run all tests in a category
terraform test -test-directory=./tests/mock -var-file="./grafana/**/configuration.tfvars" -verbose
```

**Common Test Failures**:

| Error                    | Cause                                 | Solution                                                         |
| ------------------------ | ------------------------------------- | ---------------------------------------------------------------- |
| "Unknown variable"       | Variable not in examples/variables.tf | Check variable name matches root variables.tf                    |
| "Invalid reference"      | Using wrong key format                | Use `resource_group = { key = "rg_key" }`                        |
| "Resource name too long" | Included azurecaf prefix in name      | Remove prefix, let azurecaf add it                               |
| "Network config invalid" | Using wrong variable names            | Use `vnets` and `virtual_subnets`, not `networking` or `subnets` |

### Checklist for New Examples

- [ ] Examples in numbered directories (100-xxx, 200-xxx, etc.)
- [ ] File named `configuration.tfvars` (not minimal/complete/example)
- [ ] Resource names WITHOUT azurecaf prefixes
- [ ] Key-based references for all dependencies (`resource_group = { key = "..." }`)
- [ ] global_settings with random_length
- [ ] Networking uses correct variables (`vnets`, `virtual_subnets`)
- [ ] Private DNS configuration complete (if using private endpoints)
- [ ] Added to appropriate `.github/workflows/*.json` file
- [ ] Tested locally with `terraform test`
- [ ] No hardcoded subscription IDs or resource IDs

---

##
