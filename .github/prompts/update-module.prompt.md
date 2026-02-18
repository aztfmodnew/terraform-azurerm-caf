# Update Terraform Module (Azure CAF) — safe extension

Goal: Extend an existing module without breaking users; align with provider schema; update examples and docs.

Provide these inputs:

- Module path: `modules/<category>/<module_name>/`
- Azure resource(s) impacted: e.g., `azurerm_container_app`
- Change type(s): add attribute | rename | deprecate | bugfix | diagnostics/PE enhancement
- Attributes to add/rename/remove (list)
- Examples that must be updated (list of example paths)

Baseline rules:

- All content (code, comments, docs, commits) in English.
- Follow `.github/instructions/terraform-modules.instructions.md` and repo patterns (try()/coalesce(), tags merge, locals/variables layout).
- Maintain backward compatibility. Prefer soft-deprecation and `try()` fallbacks.

Steps:

1. Validate schema
   - Compare current provider docs with module implementation (required, optional, nested blocks).
   - Capture defaults and constraints from docs.
2. Implement changes
   - Add new optional attributes using `try(var.settings.<arg>, <default or null>)`.
   - For renames, keep old argument supported via `try(old, new)` and document deprecation.
   - Use dynamic blocks where optional structures exist (keep order-stable if needed).
   - Keep lifecycle blocks static (no conditional expressions inside lifecycle).
3. Dependencies
   - Ensure dependency resolution uses coalesce() with direct IDs first, then `var.remote_objects` fallbacks.
   - If adding new dependency types, extend remote_objects wiring accordingly.
4. Diagnostics / Private Endpoints
   - If the service now supports these, add `diagnostics.tf` or `private_endpoint.tf` using standard submodules (`../../diagnostics`, `../../networking/private_endpoint`).
5. Outputs
   - Expose useful outputs consistently (id, name, resource-specific ids where appropriate).
6. Examples
   - Update `examples/<category>/<module_name>/**/configuration.tfvars` to demonstrate new features.
   - Keep names without CAF prefixes; ensure key-based references; update networking when PEs are added.
   - Add/update CI workflow JSON entries when adding new example folders.
7. Tests / Validation
   - Run terraform plan on examples; ensure no unintended diffs.
   - Verify module appears in docs; dependency graphs include new `remote_objects` where used.
8. Documentation
   - If a README exists for the module, update usage and inputs/outputs sections.
   - Note deprecations and migration hints.

Acceptance criteria:

- No breaking changes for existing examples.
- New attributes covered with try() and documented.
- Examples plan cleanly and illustrate new features.
- Docs and dependency graphs updated.

References:

- `.github/instructions/terraform-modules.instructions.md`
- `.github/instructions/terraform-examples.instructions.md`
- `.github/MODULE_STRUCTURE.md`
- Provider docs for affected resources
