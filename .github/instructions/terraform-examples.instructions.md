---
applyTo: "examples/**/*.tfvars"
---

# Copilot path-specific instructions: Examples (.tfvars)

When editing files under `examples/**`, treat them as executable tests and documentation.

- Directory and naming (MANDATORY)
  - Use numbered directories by complexity: `100-...`, `200-...`, `300-...`.
  - File name must be `configuration.tfvars` (not minimal/complete/example).
  - Exception (Multi-file pattern): For complex scenarios requiring multiple domains, multiple thematic `.tfvars` files MAY be used (e.g., `network.tfvars`, `security.tfvars`, `application_gateway.tfvars`). When using this pattern:
    - Provide a README explaining the orchestration order and example invocation.
    - Ensure CI still has a deterministic entry point (either aggregate `configuration.tfvars` or documented var-file list in workflow JSON).
    - Keep naming consistency and required blocks spread across files (must still define `global_settings` and `resource_groups` in exactly one file).

- Naming with azurecaf
  - Do NOT include azurecaf prefixes in names (e.g., use `"grafana-test-1"`, not `"rg-grafana-test-1"`).

- Required sections
  - `global_settings` with `default_region`, `regions`, and `random_length`.
  - `resource_groups` with key-based references.
  - For multi-file examples: these mandatory blocks must exist once (do NOT duplicate across files). Document in README which file holds them.
  - Service block under the right category with instance keys.

- References (Key-based preferred)
  - Use key-based references: `resource_group = { key = "rg_key" }`.
  - Alternatives supported: direct `id`, or cross-LZ with `lz_key` + `key`.

- Networking for private endpoints examples
  - Use `vnets` and `virtual_subnets` objects (not `networking` or `subnets`).
  - Include `network_security_group_definition` if NSGs are needed.
  - Include `private_dns` with `vnet_links` as required by the service.

- Application Gateway Applications Pattern (CRITICAL)
  - Variable name: Use `application_gateway_applications` (NOT `application_gateway_applications_v1`).
  - Required fields in each application:
    - `name`: The application name (used for auto-generated resource names).
    - `application_gateway_key`: References the parent Application Gateway.
    - `listeners`: Map of listener configurations with `request_routing_rule_key`.
    - `request_routing_rules`: Map of routing rules.
    - `backend_http_setting`: Settings object (singular, not plural).
    - `backend_pool`: Pool configuration object (singular, not plural).
  - Auto-generated names (DO NOT specify):
    - `backend_http_setting.name` → Module uses `application.name` automatically.
    - `backend_pool.name` → Module uses `application.name` automatically.
    - `request_routing_rules[].backend_address_pool_key` → Module associates with app's pool automatically.
    - `request_routing_rules[].backend_http_settings_key` → Module associates with app's settings automatically.
  - Explicit names required:
    - `probes[].name` → Must be explicitly provided.
    - `listeners[].name` → Must be explicitly provided.
  - Backend pool dynamic resolution:
    - For Storage Account Private Endpoints: Use `storage_accounts` block with `key` and `private_endpoint_key`.
    - Module will resolve the private IP automatically via `var.remote_objects.storage_accounts[lz_key][key].private_endpoints[pe_key].private_ip_address`.
  - Example pattern:
    ```hcl
    application_gateway_applications = {
      my_app = {
        name = "my-app"
        application_gateway_key = "my_appgw"
        listeners = { ... }
        request_routing_rules = {
          main_rule = {
            rule_type = "Basic"
            priority = 100
            # No backend_*_key - auto-associated
          }
        }
        backend_http_setting = {
          # No name - uses "my-app"
          port = 443
          protocol = "Https"
        }
        backend_pool = {
          # No name - uses "my-app"
          storage_accounts = {
            my_sa = {
              key = "sa_key"
              private_endpoint_key = "pe_key"
            }
          }
        }
        probes = {
          health = {
            name = "my-health-probe"  # Required
            protocol = "Https"
            path = "/health"
          }
        }
      }
    }
    ```

- CI integration (MANDATORY)
  - Ensure the example path is added to the appropriate workflow JSON in `.github/workflows/`.

- Testing
  - Validate with `terraform test` (mock tests) or the repository’s helper scripts.
  - Start from `100-` simple examples; build up to `200-` and `300-`.


# User Best Practices for Deployments

- It is recommended to avoid using "guest user" accounts for testing or running deployments, especially when access to protected resources such as Azure Key Vault with RBAC is required. Guest users may have additional restrictions and permission propagation issues, which can cause authorization errors (403 Forbidden) during deployment. Always use standard user accounts with the appropriate RBAC roles to ensure successful deployment.

Keep examples minimal yet realistic. Treat them as contract tests for module behavior.
