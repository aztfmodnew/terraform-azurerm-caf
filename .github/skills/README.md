# Azure CAF Terraform Framework - Agent Skills

This directory contains specialized **Agent Skills** for GitHub Copilot to improve performance on common Terraform CAF tasks.

## What are Agent Skills?

Agent Skills are folders of instructions, scripts, and resources that Copilot can automatically load when relevant. They follow the [open standard](https://github.com/agentskills/agentskills) and work with:
- GitHub Copilot Coding Agent
- GitHub Copilot CLI
- VS Code Insiders (stable support coming soon)

## Available Skills

### 🛠️ Core Skills (Piloto Phase)

#### 1. **module-creation**
Complete workflow for creating a new Azure CAF Terraform module from scratch.

**Use when:**
- Creating a new module for an Azure resource
- Starting a new module implementation
- Need step-by-step guidance for module structure

**Covers:**
- Schema validation (Pattern 0)
- Directory structure
- Standard files (providers, variables, locals, outputs)
- Diagnostics and private endpoint integration
- Mock testing
- Root module integration

**Trigger phrases:**
- "Create a new module for azurerm_*"
- "Implement module for <Azure service>"
- "Start new CAF module"

---

#### 2. **root-module-integration**
8-step process for integrating a new module into the root framework.

**Use when:**
- After creating a new module
- Need to wire module into root aggregator
- Setting up combined_objects
- Creating examples and CI integration

**Covers:**
- Creating root aggregator file
- Adding variables
- Configuring locals
- Setting up combined_objects
- Example creation
- CI/CD integration
- Testing integration

**Trigger phrases:**
- "Integrate module into root"
- "Wire up the new module"
- "Connect module to framework"
- "Set up combined objects"

---

#### 3. **mock-testing**
Execute and debug Terraform mock tests for modules.

**Use when:**
- Testing a module after creation or changes
- Debugging test failures
- Validating examples work correctly
- Before committing changes

**Covers:**
- Test execution commands
- Common error patterns and solutions
- Debugging workflow
- Test best practices

**Trigger phrases:**
- "Run mock tests"
- "Test the module"
- "Debug test failure"
- "Why is the test failing?"

---

#### 4. **azure-schema-validation**
Validate Azure resource schemas using MCP Terraform tools (Pattern 0 - MANDATORY).

**Use when:**
- Before implementing any new resource
- Before modifying existing resource
- Verifying all attributes are implemented
- Checking for deprecated resources

**Covers:**
- MCP Terraform tools usage
- Schema extraction
- Required vs optional attributes
- Nested blocks identification
- Deprecation checking

**Trigger phrases:**
- "Validate schema for azurerm_*"
- "Check resource attributes"
- "Is this resource deprecated?"
- "What attributes does azurerm_* support?"

---

#### 5. **diagnostics-integration**
Add Azure Monitor diagnostic settings to modules for logging and monitoring.

**Use when:**
- Adding diagnostics to new or existing module
- Implementing compliance logging requirements
- Setting up monitoring for Azure resources
- User asks to "enable logging" or "add monitoring"

**Covers:**
- Creating diagnostics.tf with module integration
- Configuring Log Analytics destinations
- Setting up log categories and metrics
- Retention policies and best practices
- Example creation with diagnostics

**Trigger phrases:**
- "Add diagnostics to module"
- "Enable monitoring"
- "Add diagnostic settings"
- "Set up logging"

---

#### 6. **private-endpoint-integration**
Add Azure Private Endpoint support for secure, private network connectivity.

**Use when:**
- Adding private networking to modules
- Implementing zero-trust architecture
- Disabling public access
- User asks to "add private endpoint" or "enable private connectivity"

**Covers:**
- Identifying service-specific subresource names
- Creating private_endpoint.tf
- VNet, subnet, and DNS configuration
- Network security setup
- Example creation with private endpoints

**Trigger phrases:**
- "Add private endpoint"
- "Enable private connectivity"
- "Add Azure Private Link"
- "Disable public access"

---

#### 7. **caf-naming-validation**
Validate Azure CAF naming conventions across modules and examples.

**Use when:**
- Creating modules with named resources
- Debugging naming errors (too long, invalid characters)
- Reviewing examples for compliance
- User asks to "validate names" or "check naming"

**Covers:**
- azurecaf_name.tf validation
- Resource type mapping
- Length and character constraint checking
- Prefix/suffix handling
- Example name validation

**Trigger phrases:**
- "Validate CAF naming"
- "Check naming conventions"
- "Fix naming error"
- "Why is name invalid?"

---

## How Copilot Uses Skills

When you ask Copilot to perform a task, it:

1. **Analyzes your prompt** and the current context
2. **Decides which skills are relevant** based on skill descriptions
3. **Loads the skill instructions** into its context
4. **Follows the instructions** and uses any included scripts/templates
5. **Performs the task** according to the skill's workflow

You don't need to explicitly mention the skill name - Copilot will automatically choose the right skill based on what you're asking for.

## Skills vs Custom Instructions

**Use Skills for:**
- ✅ Detailed, step-by-step workflows
- ✅ Task-specific instructions
- ✅ Context that should load only when relevant
- ✅ Including scripts and templates

**Use Custom Instructions (`.github/copilot-instructions.md`) for:**
- ✅ General repository principles
- ✅ Conventions that apply to almost every task
- ✅ High-level architecture
- ✅ Project-wide standards

**Use Path-Specific Instructions (`.github/instructions/*.md`) for:**
- ✅ File-type specific rules
- ✅ Quick reference for common patterns
- ✅ Syntax requirements by path

## Creating New Skills

To add a new skill:

1. **Create a directory** under `.github/skills/`:
   ```bash
   mkdir -p .github/skills/your-skill-name
   ```

2. **Create `SKILL.md`** with YAML frontmatter:
   ```markdown
   ---
   name: your-skill-name
   description: When to use this skill and what it does
   ---
   
   # Skill Content
   
   Detailed instructions, examples, and workflows...
   ```

3. **Add resources** (optional):
   - Scripts: `your-skill-name/script.sh`
   - Templates: `your-skill-name/template.tf`
   - Examples: `your-skill-name/example.md`

4. **Test the skill** by asking Copilot to perform the task

### Skill Naming Convention

- **Lowercase with hyphens**: `module-creation` (not `Module_Creation`)
- **Descriptive and specific**: `azure-schema-validation` (not `validation`)
- **Matches directory name**: Directory `module-creation/` → name: `module-creation`

## Planned Skills (Future Implementation)

### Phase 2 (Integration & Compliance) ✅ COMPLETED
- [x] **root-module-integration** - 8-step integration workflow
- [x] **caf-naming-validation** - Validate CAF naming conventions
- [x] **diagnostics-integration** - Add diagnostics to existing module
- [x] **private-endpoint-integration** - Add private endpoints to module

### Phase 3 (Examples & Documentation)
- [ ] **example-creation** - Create tfvars examples with correct structure
- [ ] **example-networking** - Create networking examples (VNets, private endpoints)
- [ ] **ci-workflow-integration** - Add example to CI/CD workflows

### Phase 4 (Advanced Patterns)
- [ ] **managed-identity-pattern** - Implement managed identity resolution
- [ ] **variable-settings-design** - Design settings variable with validation
- [ ] **coalesce-pattern** - Implement dependency resolution pattern
- [ ] **dynamic-blocks** - Implement dynamic nested blocks

### Phase 5 (Maintenance & Migration)
- [ ] **module-update** - Update module to new provider version
- [ ] **backward-compatibility** - Maintain backward compatibility
- [ ] **deprecation-migration** - Migrate from deprecated resource

## Skill Metrics

Track which skills are most useful:

| Skill                         | Status   | Usage | Last Updated |
|-------------------------------|----------|-------|--------------||
| module-creation               | ✅ Active | TBD   | 2026-02-19   |
| mock-testing                  | ✅ Active | TBD   | 2026-01-19   |
| azure-schema-validation       | ✅ Active | TBD   | 2026-02-19   |
| root-module-integration       | ✅ Active | TBD   | 2026-01-23   |
| diagnostics-integration       | ✅ Active | TBD   | 2026-01-23   |
| private-endpoint-integration  | ✅ Active | TBD   | 2026-01-23   |
| caf-naming-validation         | ✅ Active | TBD   | 2026-01-23   |

## Contributing

When creating or updating skills:

1. **Follow the skill structure** (YAML frontmatter + Markdown)
2. **Be specific about when to use** the skill
3. **Include examples** for clarity
4. **Test with Copilot** before committing
5. **Keep focused** - one skill per task type
6. **Update this README** when adding new skills

## MCP Terraform Server

Skills that perform schema validation require the **HashiCorp Terraform MCP Server**.

### Configuration (`.mcp.json` in project root)

```json
{
  "mcpServers": {
    "terraform": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server"]
    }
  }
}
```

### Available Tools

| Tool | Purpose |
|------|---------|
| `mcp__terraform__search_providers` | Search for a resource to obtain its numeric `provider_doc_id` |
| `mcp__terraform__get_provider_details` | Fetch full resource schema using a numeric `provider_doc_id` |
| `mcp__terraform__get_provider_capabilities` | List all resources/data-sources available in a provider |
| `mcp__terraform__get_latest_provider_version` | Get the latest version of a provider |
| `mcp__terraform__search_modules` | Search Terraform Registry for modules |
| `mcp__terraform__get_module_details` | Get details and inputs/outputs of a module |

### Correct Schema Validation Flow

```
1. mcp__terraform__search_providers(
     provider_namespace="hashicorp",
     provider_name="azurerm",
     service_slug="<resource_name>",   # e.g. "chaos_studio_target"
     provider_document_type="resources"
   )
   → Returns: provider_doc_id (numeric, e.g. "8894603")

2. mcp__terraform__get_provider_details(provider_doc_id="8894603")
   → Returns: full schema, all arguments, nested blocks, timeouts, deprecation status
```

## Resources

- [Agent Skills Standard](https://github.com/agentskills/agentskills)
- [GitHub Copilot Skills Documentation](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Awesome Copilot Collection](https://github.com/github/awesome-copilot)

## Questions?

- Check skill descriptions to understand when to use each skill
- Skills load automatically - no need to mention them explicitly
- If unsure which skill applies, describe your task naturally
- Skills complement (not replace) existing instructions
