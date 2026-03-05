# Agent Regression Test Suite

This file contains a battery of 8 smoke tests (one per agent) to validate agent functionality after configuration changes.

**When to run:** After modifying `.github/agents/*.agent.md` tool definitions or YAML frontmatter.

**How to run:** Execute each prompt with the specified agent and compare actual output against expected results below.

---

## Test 1: CI Workflow Manager

**Prompt:**
```
Find all standalone workflow JSON files in .github/workflows and count how many terraform configuration paths are defined across all of them. Return: (1) list of workflow files found, (2) total count of config_files entries across all workflows, (3) identify which workflow has the most examples.
```

**Expected Output:**
- ✅ Should find 10 workflow JSON files (9 standalone + 1 landingzone-longrunners with different structure)
- ✅ Total count ~388 config_files across all workflows
- ✅ `standalone-scenarios.json` has most examples (~157 paths)
- ✅ Should provide breakdown table by workflow file

**Capabilities Tested:** `read`, `search`, file listing, JSON parsing

---

## Test 2: Compliance Validator

**Prompt:**
```
Analyze the module at modules/cache/managed_redis/ and verify if it follows CAF standards: (1) Does it have azurecaf_name.tf for naming? (2) Does it use standard locals pattern (tags, location, resource_group_name)? (3) Does it have diagnostics.tf? (4) Does it have private_endpoint.tf? Return a compliance checklist with pass/fail for each criterion.
```

**Expected Output:**
- ✅ Identifies presence/absence of azurecaf_name.tf
- ✅ Validates locals.tf has standard pattern (tags, location, resource_group_name)
- ✅ Checks for diagnostics.tf file
- ✅ Checks for private_endpoint.tf file
- ✅ Returns structured pass/fail checklist
- ⚠️ May identify issues like missing identity block pattern

**Capabilities Tested:** `read`, `search`, pattern validation, code analysis

---

## Test 3: Documentation Sync

**Prompt:**
```
Check the module at modules/monitoring/grafana/ and verify: (1) Does a README.md exist? (2) If yes, does it document the required variables? (3) Does it have usage examples? Return findings with specific line references if README exists.
```

**Expected Output:**
- ✅ Identifies if README.md exists
- ✅ Lists required variables and checks documentation coverage
- ✅ Identifies inline examples vs missing comprehensive docs
- ✅ Provides line numbers for references
- ❌ May identify missing sections: Inputs table, Outputs, Features, Requirements

**Capabilities Tested:** `read`, documentation analysis, line referencing

---

## Test 4: Example Generator

**Prompt:**
```
Examine the example at examples/grafana/100-simple-grafana/configuration.tfvars and verify it follows CAF example standards: (1) Has global_settings with regions? (2) Uses key-based references (e.g., resource_group = { key = ... })? (3) Resource names exclude azurecaf prefixes? Return specific findings for each criterion with line numbers.
```

**Expected Output:**
- ✅ Validates global_settings structure (default_region, regions, random_length)
- ✅ Confirms key-based reference pattern (`resource_group = { key = "..." }`)
- ⚠️ **May detect naming issue:** Grafana instance name includes "grafana-" prefix (line 16) which azurecaf will duplicate
- ✅ Provides line-by-line analysis with pass/fail per criterion

**Known Issue (as of 2026-03-05):** Example at line 16 has `name = "grafana-test-1"` which should be `name = "test-1"` to avoid prefix duplication.

**Capabilities Tested:** `read`, TFVARS parsing, naming convention validation

---

## Test 5: Migration Assistant

**Prompt:**
```
Search the codebase for any modules still using the deprecated pattern 'var.module_name' (specific variable name) instead of the standard 'var.settings' pattern. Find 2-3 examples and report: (1) module path, (2) file name, (3) line number where old pattern is used. This tests search capabilities.
```

**Expected Output:**
- ✅ Finds 2-3 modules with deprecated variable patterns
- ✅ Examples may include: `modules/storage_account` (var.storage_account), `modules/subscriptions` (var.subscription_key)
- ✅ Provides module path, file name, and line numbers
- ✅ Shows variable declaration and usage context

**Capabilities Tested:** `search` (grep/semantic), pattern detection, code archaeology

---

## Test 6: Module Builder

**Prompt:**
```
WITHOUT making any changes, analyze what files would be needed to create a module for 'azurerm_redis_cache' following CAF standards. Return: (1) List of files that should exist (providers.tf, variables.tf, etc.), (2) What naming pattern should be used (module path), (3) What dependencies it typically needs (resource_group, virtual_network for private endpoints). Do NOT create any files.
```

**Expected Output:**
- ✅ Lists standard CAF module files: providers.tf, variables.tf, outputs.tf, locals.tf, azurecaf_name.tf, redis_cache.tf, diagnostics.tf, private_endpoint.tf
- ✅ Identifies correct module path: `modules/cache/redis_cache/` (two-level depth)
- ✅ Lists dependencies: resource_groups, vnets/subnets, private_dns, managed_identities, diagnostics
- ⚠️ **CRITICAL:** Should identify `azurerm_redis_cache` is DEPRECATED and recommend `azurerm_managed_redis` instead
- ✅ May note existing module at `modules/redis_cache/` is non-compliant (wrong depth)

**Capabilities Tested:** `read`, schema understanding, dependency analysis, deprecation detection

---

## Test 7: Module Updater

**Prompt:**
```
Examine the module at modules/monitoring/grafana/grafana.tf and identify: (1) What azurerm resource is used? (2) How many dynamic blocks does it have? (3) Does it use the standard identity block pattern with local.managed_identities? Return findings without making changes.
```

**Expected Output:**
- ✅ Identifies resource: `azurerm_dashboard_grafana`
- ✅ Counts 4 dynamic blocks: smtp, azure_monitor_workspace_integrations, identity, timeouts
- ❌ Identifies deviation: identity block does NOT use standard `local.managed_identities` pattern
- ✅ Explains current implementation does inline resolution instead of separate managed_identities.tf file

**Capabilities Tested:** `read`, dynamic block analysis, pattern compliance checking

---

## Test 8: Remote State Orchestrator

**Prompt:**
```
Find examples in the codebase of the coalesce pattern for dependency resolution. Look for patterns like 'coalesce(try(var.settings.xxx_id, null), try(var.remote_objects...))'. Report 2 examples with: (1) module path, (2) resource attribute using the pattern, (3) what dependency it's resolving (e.g., service_plan_id, vnet_id).
```

**Expected Output:**
- ✅ Finds 2+ examples of coalesce pattern
- ✅ Examples may include:
  - `modules/webapps/windows_web_app/windows_web_app.tf` - service_plan_id resolution
  - `modules/networking/route_server/route_server.tf` - subnet_id resolution
- ✅ Shows fallback chain: direct ID → key-based reference → remote objects
- ✅ Explains cross-landing-zone support via lz_key parameter

**Capabilities Tested:** `search` (regex/pattern matching), code snippet extraction, dependency graph understanding

---

## Summary

All 8 tests completed successfully (2026-03-05). Agent tools (`read`, `search`, `edit`, `execute`, `browser`, `microsoft-docs/*`, `agent`, `vscode`, `web`, `todo`) are functioning correctly after frontmatter corrections.

**Key Findings from Test Run:**

| Agent | Status | Notes |
|-------|--------|-------|
| CI Workflow Manager | ✅ PASS | Found 388 config paths across 10 workflows |
| Compliance Validator | ✅ PASS | Detailed compliance analysis with pass/fail checklist |
| Documentation Sync | ✅ PASS | Identified README gaps with line references |
| Example Generator | ⚠️ PASS* | *Detected naming issue in grafana example (line 16) |
| Migration Assistant | ✅ PASS | Found 3 modules with deprecated patterns |
| Module Builder | ⚠️ PASS* | *Correctly identified azurerm_redis_cache as deprecated |
| Module Updater | ⚠️ PASS* | *Detected grafana identity block doesn't follow standard pattern |
| Remote State Orchestrator | ✅ PASS | Found coalesce patterns with cross-lz support |

**Action Items from Tests:**
1. Fix grafana example name at `examples/grafana/100-simple-grafana/configuration.tfvars:16`
2. Consider migrating grafana module identity block to standard pattern (managed_identities.tf)
3. Migration candidates identified: storage_account, subscriptions modules

---

## How to Re-run

```bash
# Use runSubagent tool with each agent name and prompt from above
# Example for Test 1:
runSubagent(
  agentName: "CI Workflow Manager",
  prompt: "Find all standalone workflow JSON files in .github/workflows and count..."
)
```

Or invoke directly in Copilot:
```
@CI Workflow Manager Find all standalone workflow JSON files in .github/workflows...
```

---

**Last Validated:** 2026-03-05
**Validated Agent Config Version:** After fix-agent-tools-definitions (commit 3a19714)
**Test Execution Time:** ~90 seconds total
