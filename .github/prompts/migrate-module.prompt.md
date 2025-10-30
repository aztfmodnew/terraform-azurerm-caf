# Migrate Terraform Module (Azure CAF) — correct depth and paths

Goal: Move a module to the required path `modules/<category>/<module_name>/`, fix all relative paths, and ensure docs/tests continue to work.

Provide these inputs:

- Current path: e.g., `modules/grafana/`
- Target path: e.g., `modules/monitoring/grafana/`
- Root aggregator file(s) referencing the module
- Any known submodule paths within the module (diagnostics, private_endpoint, others)
- Example directories that reference the module

Hard requirements:

- Two-level depth is mandatory for docs discovery.
- Keep public inputs/outputs stable; avoid breaking changes.
- All content in English.

Steps:

1. Move directory
   - Relocate to `modules/<category>/<module_name>/` (module_name = resource without provider prefix, singular).
2. Update relative paths inside the module
   - Diagnostics submodule path must be `../../diagnostics` from the module root.
   - Private endpoint submodule path must be `../../networking/private_endpoint`.
   - Use `realpath` checks from the module folder to verify each `source`.
3. Update root aggregator source
   - In `/<category>_<module_names>.tf` set `source = "./modules/<category>/<module_name>"`.
   - Ensure outputs and references remain unchanged.
4. Search and replace references
   - Grep the repo for old path strings and update any remaining references in examples or docs.
5. Validate dependency wiring
   - Ensure `var.remote_objects.*` references still resolve; update combined objects if needed.
6. Regenerate docs and verify
   - Confirm the module now appears in generated docs and in dependency graphs.
7. Run examples/tests
   - `terraform plan` for example tfvars; check for unintended diffs.

Acceptance criteria:

- Module present at two-level depth and detected by docs generator.
- All relative paths confirmed via `realpath` from the module directory.
- Root aggregator updated and examples remain functional.
- No API-breaking changes to variables/outputs.

References:

- `.github/MODULE_STRUCTURE.md`
- `.github/instructions/terraform-modules.instructions.md`
- `.github/instructions/terraform-root.instructions.md`
- `.github/instructions/terraform-examples.instructions.md`
