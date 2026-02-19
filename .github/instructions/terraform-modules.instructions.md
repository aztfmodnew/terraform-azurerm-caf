---
applyTo: "modules/**/*.tf"
---

# Copilot path-specific instructions: Terraform modules

Use these rules when editing files under `modules/**`. Focus on correctness, CAF conventions, and backward compatibility.

**See also**: `variable-settings-definition.md` for detailed settings variable design standards

- CAF naming (MANDATORY)
  - Every named resource must use `azurecaf_name` in `azurecaf_name.tf` and assign `name = azurecaf_name.<id>.result` in the resource.
  - Use the correct `resource_type` for the Azure resource (see Appendix A in main instructions).

- Standard variables and locals (MANDATORY)
  - Variables: `global_settings`, `client_config`, `location`, `settings`, `resource_group`, `base_tags`, `remote_objects`.
    - **CRITICAL**: Use generic `settings` variable (not resource-specific like `managed_redis`, `cdn_frontdoor_profile`, etc.)
    - In root aggregator file, pass each resource as: `settings = each.value` (NOT `managed_redis = each.value` or `cdn_frontdoor_profile = each.value`)
    - Within the module, reference configuration as `var.settings.<attribute>` consistently
    - **Settings variable definition MUST include**:
      - Type definition as `object()` with all supported attributes listed (not generic `any`)
      - Each attribute must be explicitly typed (e.g., `string`, `optional(bool)`, `optional(map(string))`)
      - DESCRIPTION block (using `<<DESCRIPTION ... DESCRIPTION` syntax) documenting:
        - Purpose of the settings object
        - List of all supported attributes with their descriptions
        - Whether each attribute is required or optional
        - Constraints and valid values from the Azure provider documentation
      - Validation block that checks no unsupported attributes are provided (see example below)
      - **Example**:
        ```hcl
        variable "settings" {
          description = <<DESCRIPTION
            Settings object for the Azure Resource. Configuration attributes:
              - name - (Required) Name of the resource
              - enabled - (Optional) Whether to enable the resource. Defaults to true.
              - tags - (Optional) Tags to assign to the resource.
            DESCRIPTION
          type = object({
            name     = string
            enabled  = optional(bool)
            tags     = optional(map(string))
          })
          validation {
            condition = length(setsubtract(keys(var.settings), ["name", "enabled", "tags"])) == 0
            error_message = "Unsupported attributes in settings. Allowed: name, enabled, tags."
          }
        }
        ```
  - Locals: compute `module_tag`, `tags = merge(...)`, `location`, `resource_group_name` using the standard block.

- Pattern 0: Validate resource schema
  - Before adding/altering resource arguments, validate ALL attributes using Terraform azurerm docs. Required -> present; optional -> `try(var.settings.<arg>, null)`; nested -> dynamic blocks; include a `timeouts` dynamic block.
  - If the provider doc marks a resource as deprecated in the provider docs, do NOT implement it; use the non-deprecated replacement resource instead.

- Diagnostics integration (MANDATORY when supported)
  - Create `diagnostics.tf`. Always:
    - `module "diagnostics" { source = "../../diagnostics" for_each = try(var.settings.diagnostic_profiles, {}) resource_id = azurerm_<type>.<name>.id resource_location = azurerm_<type>.<name>.location diagnostics = var.remote_objects.diagnostics profiles = try(var.settings.diagnostic_profiles, {}) }`

- Private endpoint integration (MANDATORY when supported)
  - Do NOT create `azurerm_private_endpoint` here.
  - Expose id/subresource via outputs; instantiate `../networking/private_endpoint` submodule with `for_each = var.private_endpoints` and pass `resource_id`, `subnet_id` via the coalesce pattern.
  - Module variables: `private_endpoints`, `private_dns`, `virtual_subnets`, `vnets` with defaults `{}`.

- Dependency resolution (MANDATORY)
  - Use the coalesce pattern with `var.settings.*`, `var.remote_objects.<plural>`, and cross-landing-zone lookups. Never pass raw IDs as separate variables between submodules—use `remote_objects`.
  - **Prefer `try(coalesce(), null)` over nested `can()` ternaries** for optional dependency resolution:
    ```hcl
    # ❌ AVOID: nested can() ternary — hard to read and extend
    resource_id = can(each.value.resource_id) ? each.value.resource_id : can(each.value.resource_key) ? var.remote_objects.resources[...][each.value.resource_key].id : null

    # ✅ PREFER: try(coalesce()) — each path explicit, easy to add cross-LZ fallbacks
    resource_id = try(coalesce(
      try(each.value.resource_id, null),
      try(var.remote_objects.resources[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.resource_key].id, null)
    ), null)
    ```
    The outer `try(..., null)` is required when the attribute is optional — `coalesce()` throws if all arguments are null. For **required** dependencies (where at least one path must resolve), `coalesce()` alone is sufficient and the error is desirable.
  - For identity blocks: Create dedicated `managed_identities.tf` file that resolves managed identity IDs from `var.remote_objects.managed_identities` supporting both local (same landing zone) and remote (cross-landing-zone) references via `settings.identity.managed_identity_keys` and `settings.identity.remote` patterns.

- Dynamic blocks
  - Optional single block: `for_each = var.settings.<block> == null ? [] : [var.settings.<block>]`.
  - Multiple from list: `for_each = try(var.settings.<blocks>, [])`.
  - Multiple from map: `for_each = try(var.settings.<blocks>, {})`; prefer map when you need stable keys.
  - Identity blocks: use dedicated `managed_identities.tf` with locals that flatten and concatenate local and remote identity references, then use in resource's dynamic identity block.

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

- Testing (MANDATORY)
  - After creating or updating a module, run mock tests from `examples/` directory:
    - `cd examples && terraform init -upgrade`
    - `terraform test -test-directory=./tests/mock -var-file=./category/service/100-example/configuration.tfvars -verbose`
  - Mock tests must pass before committing changes
  - If tests fail with "Reference to undeclared input variable", verify all references use `var.settings` (not resource-specific variable names)
  - If tests fail with "Invalid reference" in dynamic blocks, check for reserved keywords (e.g., `module`) used as iterator names

If unsure, prefer existing module patterns (e.g., `network_manager`, `cdn_frontdoor_profile`). Keep changes minimal and backward compatible.
