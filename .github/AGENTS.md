# 🤖 Available Agents - terraform-azurerm-caf

This document lists all AI agents available for **module creation, updates, testing, and integration** in the terraform-azurerm-caf repository.

---

## 🏗️ Module Development Agents

### **Module Builder**
**Purpose:** Create a complete, production-ready Terraform module from scratch following CAF standards.

**When to use:**
- "Create a module for azurerm_storage_account"
- "I need a new module for Azure Cosmos DB"
- "Generate a Terraform module for Service Bus"

**What it does:**
- Creates complete directory structure: `modules/category/service/`
- Generates all standard files: `providers.tf`, `variables.tf`, `outputs.tf`, `locals.tf`, `azurecaf_name.tf`, `service.tf`
- Adds optional: `diagnostics.tf`, `private_endpoint.tf`
- Creates examples (100-simple, 200-advanced)
- Runs mock tests to validate
- Provides integration checklist

**Example invocation:**
```
"Create a module for azurerm_api_management with diagnostics and private endpoint support"
```

**Related skill:** [module-creation/SKILL.md](.github/skills/module-creation/SKILL.md)

---

### **Module Updater**
**Purpose:** Expert agent for updating existing modules with new features, attributes, or bug fixes following CAF standards.

**When to use:**
- "Add customer-managed encryption to the KeyVault module"
- "Update managed identity support in App Service"
- "Fix the issue where role assignments aren't being processed"
- "Add diagnostic settings to the Storage Account module"

**What it does:**
- Analyzes module structure and current attributes
- Validates new attributes with Azure provider schema (MCP Terraform)
- Maintains backward compatibility
- Updates examples with new features
- Runs mock tests to confirm changes work
- Updates documentation

**Example invocation:**
```
"Add managed identity support to the cache/managed_redis module with system-assigned and user-assigned options"
```

**Related skills:**
- [azure-schema-validation/SKILL.md](.github/skills/azure-schema-validation/SKILL.md)
- [diagnostics-integration/SKILL.md](.github/skills/diagnostics-integration/SKILL.md)
- [private-endpoint-integration/SKILL.md](.github/skills/private-endpoint-integration/SKILL.md)

---

## 🧪 Testing & Validation Agents

### **Compliance Validator**
**Purpose:** Validates Terraform code against CAF standards, Azure best practices, and organizational policies.

**When to use:**
- "Validate this module against CAF naming standards"
- "Check if my examples follow the naming convention"
- "Ensure all modules have diagnostics and private endpoints"

**What it does:**
- Checks CAF naming conventions
- Validates module structure (2-level depth)
- Confirms required files exist
- Verifies examples use key-based references
- Detects hardcoded IDs or credentials
- Validates standard locals pattern

**Example invocation:**
```
"Check if all modules in the database/ category follow CAF standards"
```

---

### **Example Generator**
**Purpose:** Generates consistent, realistic .tfvars examples at multiple complexity levels following CAF standards.

**When to use:**
- "Create a 200-advanced example for the App Gateway module"
- "Generate minimal and complete examples for the new Cosmos DB module"
- "I need examples showing private endpoint integration"

**What it does:**
- Creates numbered directories: 100-simple, 200-intermediate, 300-advanced
- Generates realistic resource configurations
- Uses key-based references (not hardcoded IDs)
- Includes networking setup for private endpoint examples
- Adds explanatory comments
- Validates examples with mock tests

**Example invocation:**
```
"Create a 200-advanced example for cache/managed_redis showing private endpoint, diagnostics, and managed identities"
```

**Related skill:** [mock-testing/SKILL.md](.github/skills/mock-testing/SKILL.md)

---

## 🔌 Integration Agents

### **CAF Orchestrator**
**Purpose:** Coordinates multi-step module workflows by delegating to specialized agents.

**When to use:**
- "Create a new module for Container Registry with all integrations"
- "Add private endpoint support to three modules in parallel"
- "Generate a complete feature set for Azure Kubernetes Service"

**What it does:**
- Sequences tasks: create → integrate root → add diagnostics → add examples → wire CI/CD → test
- Invokes specialized agents (Module Builder, Example Generator, etc.)
- Tracks progress across steps
- Validates each step before proceeding
- Provides consolidated summary

**Example invocation:**
```
"Create a complete module for azurerm_container_registry with diagnostics, private endpoints, networking integration, and examples"
```

---

### **CI Workflow Manager**
**Purpose:** Manages GitHub Actions workflows for automated testing, ensuring every example is tested in CI/CD pipelines.

**When to use:**
- "Add the new managed_redis example to CI/CD"
- "I created a new example but it's not in the CI pipeline"
- "How do I register this example for automated testing?"

**What it does:**
- Identifies the correct workflow file (standalone-scenarios.json, standalone-compute.json, etc.)
- Adds example path to workflow matrix
- Verifies configuration syntax
- Ensures deterministic test execution
- Documents workflow location

**Example invocation:**
```
"Add examples/cognitive_services/openai/100-simple-openai to the CI/CD pipeline"
```

**Related instruction:** [.github/instructions/terraform-examples.instructions.md](.github/instructions/terraform-examples.instructions.md#cicd-workflow-integration-mandatory)

---

## 🔍 Root Integration Agent

### **Root Module Integration**
**Purpose:** Completes the 8-step workflow for integrating a new module into the root framework.

**When to use:**
- "Wire this new module into the root aggregators"
- "I created the module, now how do I integrate it?"
- "Update the root files so the module works with caf-terraform-landingzones"

**What it does:**
- Creates root aggregator file (`category_services.tf`)
- Adds variable to `/variables.tf`
- Updates `/locals.tf` with module extraction
- Updates `/locals.combined_objects.tf` for cross-module references
- Creates minimal and complete examples
- Adds example paths to workflows.json
- Provides integration checklist

**The 8 Steps:**
1. Create root aggregator file
2. Add variable definition
3. Add module to locals.tf
4. Add to combined_objects
5. Create minimal example
6. Create complete example
7. Add to CI/CD workflows
8. Test integration

**Example invocation:**
```
"Integrate the cognitive_services/ai_services module into the root framework"
```

**Related skill:** [root-module-integration/SKILL.md](.github/skills/root-module-integration/SKILL.md)

---

## 🛠️ Specialized Feature Agents

### **Private Endpoint Integration Specialist**
**Purpose:** Adds Azure Private Endpoint integration to modules for secure, private network connectivity.

**When to use:**
- "Add private endpoint support to the Application Gateway module"
- "Create a private_endpoint.tf file for the SQL Database module"

**What it does:**
- Creates `modules/networking/private_endpoint/` submodule (if needed)
- Implements dynamic private endpoint block
- Handles DNS zone integration
- Configures network ACLs
- Updates examples with PE configuration
- Updates documentation

**Example invocation:**
```
"Add private endpoint support to the app_service module with DNS and network ACL integration"
```

**Related skill:** [private-endpoint-integration/SKILL.md](.github/skills/private-endpoint-integration/SKILL.md)

---

### **Diagnostics Integration Specialist**
**Purpose:** Adds Azure Monitor diagnostic settings to modules for monitoring and logging.

**When to use:**
- "Add diagnostic settings support to the API Management module"
- "Implement diagnostics for the Virtual Network module"

**What it does:**
- Creates `diagnostics.tf` file with standard patterns
- Implements dynamic diagnostic blocks
- Handles Log Analytics workspace references
- Updates examples with diagnostics configuration
- Validates diagnostic category support

**Example invocation:**
```
"Add comprehensive diagnostics support to the cache/managed_redis module"
```

**Related skill:** [diagnostics-integration/SKILL.md](.github/skills/diagnostics-integration/SKILL.md)

---

### **Schema Validation Specialist**
**Purpose:** Validates Azure Terraform resource schemas using MCP Terraform tools.

**When to use:**
- "Validate that all Arguments for azurerm_app_service are implemented"
- "Check if I've missed any nested blocks in the storage account resource"
- "Ensure the module matches the current Azure provider schema"

**What it does:**
- Fetches complete provider documentation
- Validates all required arguments are implemented
- Identifies optional arguments not yet supported
- Checks for deprecated attributes
- Reports discrepancies

**Example invocation:**
```
"Validate that the networking/virtual_network module implements all attributes from the azurerm_virtual_network resource"
```

**Related skill:** [azure-schema-validation/SKILL.md](.github/skills/azure-schema-validation/SKILL.md)

---

## 📚 Usage Examples

### Scenario 1: Create a Complete New Module

```
User: "Create a module for azurerm_app_configuration with all enterprise features"

Workflow:
1. Module Builder creates structure and resources
2. Private Endpoint Integration adds PE support
3. Diagnostics Integration adds monitoring
4. Example Generator creates 100, 200, 300 examples
5. CI Workflow Manager registers examples
6. Root Module Integration wires into framework
7. Compliance Validator confirms standards
8. All ready for PR! ✅
```

**Invoke:**
```
Agent: CAF Orchestrator
Prompt: "Create a complete module for azurerm_app_configuration with private endpoints, diagnostics, managed identities, and examples"
```

---

### Scenario 2: Add Feature to Existing Module

```
User: "The SQL Database module needs managed identity support"

Workflow:
1. Module Updater adds managed identity block
2. Example Generator creates example showing MI usage
3. Mock testing validates changes
4. CI Workflow Manager updates example tests
5. Change ready for PR! ✅
```

**Invoke:**
```
Agent: Module Updater
Prompt: "Add system-assigned and user-assigned managed identity support to database/mssql_database module"
```

---

### Scenario 3: Validate Entire Category

```
User: "Are all networking modules compliant with CAF standards?"

Workflow:
1. Compliance Validator checks all modules
2. Reports missing features or naming issues
3. Suggests fixes
```

**Invoke:**
```
Agent: Compliance Validator
Prompt: "Validate all modules in the networking/ category against CAF standards and CAF naming conventions"
```

---

## 📋 Agent Selection Guide

```
┌─────────────────────────────────────────┐
│  What do you need to do?                │
└────────────────┬────────────────────────┘
                 │
    ┌────────────┼────────────┬──────────────────┐
    │            │            │                  │
    ▼            ▼            ▼                  ▼
Create?     Update?      Test?          Integrate?
    │            │            │                  │
    ▼            ▼            ▼                  ▼
Module      Module       Example         Root Module
Builder     Updater      Generator       Integration
    │            │            │                  │
    └────────────┴────────────┴──────────────────┘
                      │
                      ▼
            CAF Orchestrator
          (multi-step workflows)
```

---

## 🎓 When to Ask an Agent vs. Manual Work

| Task | Agent | Manual |
|------|-------|--------|
| Create new service module | ✅ Module Builder | ❌ |
| Add feature to module | ✅ Module Updater | ❌ |
| Create testing examples | ✅ Example Generator | ❌ |
| Check schema compliance | ✅ Schema Validator | ❌ |
| Quick file edit (1-2 changes) | ❌ | ✅ |
| Validate CAF standards | ✅ Compliance Validator | ❌ |
| Multi-step module project | ✅ CAF Orchestrator | ❌ |
| Add PE to single module | ✅ or Manual | ✅ or Agent |
| Register example in CI | ✅ CI Workflow Manager | ❌ (error-prone) |

---

## 🚀 Quick Reference

| Agent | Time Est. | Complexity | When Stuck |
|-------|-----------|-----------|-----------|
| Module Builder | 15-20 min | High | Check module-creation skill |
| Module Updater | 10-15 min | Medium | Check azure-schema-validation skill |
| Example Generator | 5-10 min | Low | Check terraform-examples.instructions.md |
| Compliance Validator | 5 min | Low | Check copilot-instructions.md |
| CAF Orchestrator | 30-45 min | Very High | Check skills in order |
| CI Workflow Manager | 5 min | Low | Check workflows/*.json structure |
| Root Integration | 20-30 min | High | Check root-module-integration skill |

---

## 📚 Related Documentation

- [Module Creation Skill](.github/skills/module-creation/SKILL.md)
- [Root Integration Skill](.github/skills/root-module-integration/SKILL.md)
- [Copilot Instructions](.github/copilot-instructions.md)
- [Module Structure Instructions](.github/instructions/terraform-modules.instructions.md)
- [Example Standards](.github/instructions/terraform-examples.instructions.md)

---

**Last Updated:** March 2026  
**Namespace:** aztfmodnew/terraform-azurerm-caf  
**Active Agents:** 10 (with 7 specialized subagents via skills)
