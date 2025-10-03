---
applyTo: 'examples/**.tfvars'
---

# Azure CAF Examples - AI Coding Guidelines

## Project Context for AI Agents

This is the Azure Cloud Adoption Framework (CAF) Terraform module repository. When working on `/examples/**` files, understand that:

**Purpose**: Examples serve dual roles as living documentation AND automated test cases. Every configuration must be both educational and functionally correct.

**Architecture**: Three-layer system where examples demonstrate how to compose the root CAF module through `.tfvars` files that are consumed by the main module in parent directory.

**Testing Approach**: All examples are validated using `terraform test` with mock providers from `/examples/tests/mock/` directory. Never assume real Azure resources exist.

When creating a new example, always search the repository's existing `examples/` directory for similar example patterns or tfvars that can be reused or adapted. Reusing existing examples reduces duplication, ensures consistency with repository conventions, and helps avoid missing fields or unsupported structures.

## Critical AI Guidelines for Code Generation

### 1. Always Use Key-Based Resource References
The CAF framework uses a sophisticated key-based dependency resolution system. **Never generate hardcoded resource IDs.**

```hcl
# ✅ AI SHOULD Generate This Pattern:
storage_accounts = {
  my_storage = {
    resource_group_key = "my_rg"  # Key reference, resolved by framework
    network_rules = {
      virtual_network_subnet_ids = [
        {
          virtual_network_key = "my_vnet"  # Key reference
          subnet_key = "my_subnet"         # Key reference
        }
      ]
    }
  }
}

# ❌ AI MUST NOT Generate This:
storage_accounts = {
  my_storage = {
    resource_group_name = "/subscriptions/.../resourceGroups/rg-my-rg-001"
  }
}
```

**AI Rule**: When generating any resource configuration, scan the resource for dependencies and use `_key` suffixed properties to reference other resources by their map keys.

Note: the CAF examples primarily prefer key-based references (the `_key` form) because they integrate with the framework's map-based resolution and example tests. However, the examples should also support the direct identifier form when an explicit resource ID is required. In practice this means you may provide either `resource_group_key` (preferred) or `resource_group_id` depending on the scenario — both are accepted by the framework and tests. When possible prefer `_key` in examples so tests stay self-contained and portable.

Examples:

```hcl
# Key-based reference (preferred within examples/tests)
storage_accounts = {
  my_storage = {
    resource_group_key = "my_rg"
  }
}

# Direct id reference (allowed when an explicit id is required)
storage_accounts = {
  my_storage = {
    resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-my-rg-001"
  }
}
```

### 2. Understand Variable Validation Context
When AI encounters Terraform validation errors, check `/examples/variables.tf` to understand available variables. Common mistakes:

```hcl
# ❌ These variables DON'T exist:
private_dns_zones = { ... }
private_dns_zone_vnet_links = { ... }

# ✅ These variables DO exist:
private_dns = { ... }
private_dns_vnet_links = { ... }
```

**AI Rule**: Before generating configurations with new variable names, verify the variable exists in `/examples/variables.tf`. If unsure, follow existing example patterns.

Note: verifying the variable exists is only the first step. Once you see a variable (for example `storage_accounts` in `/examples/variables.tf`), follow where it is consumed — open the module or the `.tf` file that implements it (for example `storage_accounts.tf` or the module under `/modules/...`) and inspect the supported attributes, nested blocks and expected types. This tells you what keys and sub-keys are valid in examples/tests (network_rules, identity, private_endpoints, etc.).

If you trace down to actual provider resources (resource blocks), use the Terraform MCP tools to fetch provider/resource documentation or to resolve provider doc IDs so you can confirm required and optional arguments and identify any missing parameters to add to the example. This ensures examples remain accurate and the `terraform test` validation will pass. Prefer `_key` references for portability, but verify all resource-level required arguments are present using provider docs when needed.

### 3. Private Endpoint Configuration Pattern
AI must use this specific structure for private endpoints (learned from actual framework code):

```hcl
# ✅ Correct structure AI should generate:
private_endpoints = {
  vnet_name = {                    # Top-level key is VNet identifier
    vnet_key = "my_vnet"
    subnet_keys = ["my_subnet"]
    resource_group_key = "my_rg"
    
    storage_accounts = {           # Service-specific section
      storage_key = {
        private_service_connection = {
          name = "psc-storage-name"
          subresource_names = ["blob"]  # Azure service subresource
        }
        private_dns = {
          zone_group_name = "default"
          keys = ["dns_zone_key"]       # Reference to private_dns keys
        }
      }
    }
  }
}
```

**AI Rule**: Never generate flat private endpoint structures or use non-existent fields like `private_dns_zone_key`.

### 4. Network Security Considerations
AI should understand the mutual exclusivity of certain network features:

```hcl
# ✅ For Private Endpoints:
subnets = {
  my_subnet = {
    private_endpoint_network_policies_enabled = true
    # DO NOT include service_endpoints
  }
}

# ✅ For Service Endpoints (alternative approach):
subnets = {
  my_subnet = {
    service_endpoints = ["Microsoft.Storage"]
    # DO NOT include private_endpoint_network_policies_enabled = true
  }
}
```

**AI Rule**: When generating subnet configurations, choose either Private Endpoints OR Service Endpoints for the same service, never both.

## AI Decision-Making Framework

### When Generating Storage Account Configurations:
1. **Ask**: "Is this using Private Endpoints or Service Endpoints?"
2. **If Private Endpoints**: Set `public_network_access_enabled = false` and `default_action = "Deny"`
3. **If Service Endpoints**: Set `default_action = "Allow"` and include subnet references

### When Generating Private DNS:
1. **Always check**: Does the variable `private_dns` exist? (Yes)
2. **Pattern**: Use `private_dns_vnet_links` with `private_dns_key` field
3. **Never use**: `private_dns_zones` or `private_dns_zone_vnet_links`

### When Generating Cross-Resource References:
1. **Scan for**: Any field ending in `_id` that might need a resource reference
2. **Replace with**: Corresponding `_key` field that references the resource map key
3. **Verify**: The target resource exists in the same configuration file

### When Encountering Terraform Errors:
1. **First**: Check if the variable exists in `/examples/variables.tf`
2. **Second**: Look for similar patterns in other example files
3. **Third**: Verify the module source code structure in `/modules/`

## Testing and Validation Context

**AI Understanding**: Every configuration you generate will be tested with:
```bash
terraform test -test-directory=./tests/mock -var-file="./path/to/example.tfvars"
```

**Implication**: All resources must be properly defined and cross-referenced. Missing keys or invalid structures will cause test failures.

**AI Responsibility**: Ensure generated configurations are self-contained and all referenced keys exist within the same file or are standard CAF framework keys.

This guidance helps AI agents understand the specific patterns, constraints, and decision-making required for the Azure CAF Terraform framework.