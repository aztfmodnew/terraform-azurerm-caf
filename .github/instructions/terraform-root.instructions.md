---
applyTo: "/*.tf"
---

# Copilot path-specific instructions: Root aggregator files

When editing Terraform at the repo root (aggregators), wire modules consistently and expose outputs for consumption by other stacks.

- Variables and locals
  - Add a category variable in `variables.tf` (e.g., `variable "cognitive_services" { default = {} }`).
  - Extend the category map in `locals.tf` to expose each submodule config: `new_module = try(var.category.new_module, {})`.

- Module call (aggregator file)
  - `source = "./modules/<category>/<module_name>"`
  - `for_each = local.<category>.<module_name_plural>`
  - Pass standard arguments: `global_settings`, `client_config`, `location = try(each.value.location, null)`, `base_tags`, `resource_group`, `resource_group_name`, `settings = each.value`.
  - Private endpoints (if supported): `private_endpoints = try(each.value.private_endpoints, {})`.

- remote_objects
  - Always pass a `remote_objects` map merging core dependencies:
    - `resource_groups = local.combined_objects_resource_groups`
    - `diagnostics = local.combined_diagnostics`
    - Networking (if private endpoints): `vnets`, `virtual_subnets`, `private_dns = local.combined_objects_private_dns`
    - Service-specific combined objects as needed (key vaults, storage, etc.)

- Combined objects (locals.combined_objects.tf)
  - Create `combined_objects_<module_name_plural> = merge(tomap({ (local.client_config.landingzone_key) = module.<module_name_plural> }), lookup(var.remote_objects, "<module_name>", {}), lookup(var.data_sources, "<module_name>", {}))`
  - Use pluralized names; follow existing naming patterns.

- Outputs
  - `output "<module_name_plural>" { value = module.<module_name_plural> }`

- Dependency resolution at this layer
  - Ensure submodules receive IDs only via their own coalesce pattern; don’t pass raw IDs unless documented as supported.

- File naming
  - Use `<category>_<module_name_plural>.tf` (or the category-specific aggregator file if it already exists).

Prefer existing aggregator patterns (e.g., `cognitive_services_account`, `cdn_cdn_frontdoor_profile`). Keep the interface stable and backward compatible.
