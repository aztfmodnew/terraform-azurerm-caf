# New Terraform Module (Azure CAF) — scaffold and wire

Goal: Create a production-ready module under `modules/<category>/<module_name>/`, wire it at the root, and ship runnable examples that follow CAF and repo standards.

Provide these inputs:

- Azure resource: azurerm\_<resource> (e.g., azurerm_container_app)
- Category: <category> (e.g., cognitive_services, networking, compute)
- Module name: <module_name> (resource name without provider prefix, singular; e.g., container_app)
- Supports diagnostics: true|false
- Supports private endpoints: true|false
- Required attributes (list)
- Optional attributes (list)
- Dependencies via remote_objects (keys you plan to use)
- Examples to generate: 100-simple, optionally 200-private-endpoint, 300-advanced

Constraints and guardrails:

- All content (code, comments, docs, commit messages) MUST be in English.
- Use the two-level depth structure: `modules/<category>/<module_name>/` (mandatory for docs generator).
- Follow `.github/instructions/terraform-modules.instructions.md` and `.github/MODULE_STRUCTURE.md`.
- Use CAF naming via `azurecaf_name.tf` and standard locals/variables patterns.
- Use try() for optional fields and coalesce() for dependency resolution.
- Use merge(local.tags, try(var.settings.tags, null)) for tags.
- Prefer key-based references and remote_objects over hardcoded IDs.

Expected artifacts (files):

- modules/<category>/<module_name>/
  - providers.tf (azurerm, azurecaf, azapi if needed)
  - variables.tf (global_settings, client_config, location, resource_group, base_tags, settings:any, remote_objects:any)
  - locals.tf (module_tag, tags, location, resource_group_name, managed identities if needed)
  - azurecaf_name.tf (CAF naming for named resources)
  - <module_name>.tf (main resource implementation)
  - diagnostics.tf (if supports diagnostics)
  - private_endpoint.tf (if supports PE)
  - outputs.tf (id, name, and useful outputs)

Implementation notes:

- Main resource (<module_name>.tf):
  - location = local.location (only if resource supports it per provider docs)
  - resource_group_name = local.resource_group_name (if applicable)
  - tags = merge(local.tags, try(var.settings.tags, null))
  - For each argument:
    - If required: argument = try(var.settings.argument, null) and validate accordingly
    - If optional: argument = try(var.settings.argument, null)
    - If default: argument = try(var.settings.argument, <default>)
  - Dependencies: resolve with coalesce() using direct IDs first, then remote_objects fallbacks
- Diagnostics: integrate using existing repo diagnostics module at `../../diagnostics` when supported
- Private endpoint: integrate using `../../networking/private_endpoint` when supported (ensure private DNS wiring in examples)

Root wiring (required):

1. Create `/ <category>_<module_names>.tf` aggregator at repo root
   - Call the module with `for_each` from `local.<module_names>`
   - Pass base variables and `remote_objects`
   - Expose outputs for combined objects
2. Update `/variables.tf` — add `<category>` variable with your module map
3. Update `/locals.tf` — project `var.<category>.<module_name>` into `local.<module_names>`
4. Update `/locals.combined_objects.tf` — expose `local.combined_objects_<module_names>` for downstream modules

Examples (required):

- examples/<category>/<module_name>/
  - 100-simple-service/configuration.tfvars (mandatory minimal)
  - 200-.../configuration.tfvars (private endpoint if supported)
  - 300-.../configuration.tfvars (advanced)

Example rules:

- Do NOT include CAF prefixes in names (e.g., use `grafana-test-1`, not `rg-grafana-test-1`).
- Use key-based references: `resource_group = { key = "rg_key" }`.
- Include `global_settings.random_length` to ensure unique naming.
- For networking examples: use `vnets` and `virtual_subnets`; include NSG definitions and private DNS when using PEs.
- Add example paths to the correct workflow JSON under `.github/workflows/`.

Acceptance criteria:

- Module compiles (terraform validate) and examples plan successfully.
- Module appears in docs (two-level depth) and dependency graphs resolve (including `var.remote_objects.*`).
- Root aggregator, variables, locals, and combined_objects updated.
- Code follows try()/coalesce() patterns and tag/location/resource_group standards.

Helpful references:

- `.github/instructions/terraform-modules.instructions.md`
- `.github/instructions/terraform-root.instructions.md`
- `.github/instructions/terraform-examples.instructions.md`
- `.github/MODULE_STRUCTURE.md`
- aztfmod/azurecaf provider docs
