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

- CI integration (MANDATORY)
  - Ensure the example path is added to the appropriate workflow JSON in `.github/workflows/`.

- Testing
  - Validate with `terraform test` (mock tests) or the repository’s helper scripts.
  - Start from `100-` simple examples; build up to `200-` and `300-`.

Keep examples minimal yet realistic. Treat them as contract tests for module behavior.
