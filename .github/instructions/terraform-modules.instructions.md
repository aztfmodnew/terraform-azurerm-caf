---
applyTo: "modules/**/*.tf"
---

# Copilot path-specific instructions: Terraform modules

Use these rules when editing files under `modules/**`. Focus on correctness, CAF conventions, and backward compatibility.

- CAF naming (MANDATORY)
  - Every named resource must use `azurecaf_name` in `azurecaf_name.tf` and assign `name = azurecaf_name.<id>.result` in the resource.
  - Use the correct `resource_type` for the Azure resource (see Appendix A in main instructions).

- Standard variables and locals (MANDATORY)
  - Variables: `global_settings`, `client_config`, `location`, `settings`, `resource_group`, `base_tags`, `remote_objects`.
  - Locals: compute `module_tag`, `tags = merge(...)`, `location`, `resource_group_name` using the standard block.

- Pattern 0: Validate resource schema
  - Before adding/altering resource arguments, validate ALL attributes using Terraform azurerm docs. Required -> present; optional -> `try(var.settings.<arg>, null)`; nested -> dynamic blocks; include a `timeouts` dynamic block.

- Diagnostics integration (MANDATORY when supported)
  - Create `diagnostics.tf`. Always:
    - `module "diagnostics" { source = "../../diagnostics" for_each = try(var.settings.diagnostic_profiles, {}) resource_id = azurerm_<type>.<name>.id resource_location = azurerm_<type>.<name>.location diagnostics = var.remote_objects.diagnostics profiles = try(var.settings.diagnostic_profiles, {}) }`

- Private endpoint integration (MANDATORY when supported)
  - Do NOT create `azurerm_private_endpoint` here.
  - Expose id/subresource via outputs; instantiate `../networking/private_endpoint` submodule with `for_each = var.private_endpoints` and pass `resource_id`, `subnet_id` via the coalesce pattern.
  - Module variables: `private_endpoints`, `private_dns`, `virtual_subnets`, `vnets` with defaults `{}`.

- Dependency resolution (MANDATORY)
  - Use the coalesce pattern with `var.settings.*`, `var.remote_objects.<plural>`, and cross-landing-zone lookups. Never pass raw IDs as separate variables between submodules—use `remote_objects`.

- Dynamic blocks
  - Optional single block: `for_each = var.settings.<block> == null ? [] : [var.settings.<block>]`.
  - Multiple from list: `for_each = try(var.settings.<blocks>, [])`.
  - Multiple from map: `for_each = try(var.settings.<blocks>, {})`; prefer map when you need stable keys.

- Lifecycle and constraints
  - `ignore_changes` must be static. Use `create_before_destroy` for resources with tight dependencies when needed.
  - Use `location = local.location`, `resource_group_name = local.resource_group_name` consistently.
  - `tags = merge(local.tags, try(var.settings.tags, null))`.

- Structure and paths (CRITICAL)
  - Module path depth must be `modules/<category>/<module_name>/`.
  - Shared module paths from module root: `../../diagnostics`, `../../networking/private_endpoint`.

- Submodules pattern
  - Parent calls child submodules with plural names and passes dependencies via `remote_objects = merge(var.remote_objects, { <dep> = <resource or module> })`.
  - In the child, resolve parents/siblings via coalesce on `var.settings.*` and `var.remote_objects.*`.

- Outputs
  - Expose IDs and important values; use pluralized output names for collections (e.g., `endpoints`, `origin_groups`).

If unsure, prefer existing module patterns (e.g., `network_manager`, `cdn_frontdoor_profile`). Keep changes minimal and backward compatible.
