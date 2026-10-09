---
name: module-coverage-audit
description: Audit Terraform CAF modules across providers for missing supported resource arguments, nested resources, outputs, examples, and tests. Use for repository-wide or category-wide module coverage work.
---

# Terraform CAF Module Coverage Audit

Use this workflow to identify and implement verified capability gaps in existing modules without replacing their provider patterns or breaking existing settings.

## Inventory

From the repository root, generate a deterministic inventory with the bundled standard-library script:

```bash
python .github/skills/module-coverage-audit/scripts/inventory.py \
  --root . \
  --output tmp/module-coverage.tsv
```

The script lists every directory under `modules/` that contains Terraform files, classifies it by depth and direct block usage, and reports resource/data-source types, provider families, and child module calls. It also includes audit, implementation, test, and stack tracking columns. When regenerating an existing output file, it preserves those progress columns for paths that still exist. It does not decide whether an implementation is complete. Keep audit notes and generated inventory in a verified ignored temporary directory; do not commit them as implementation documentation.

Classify each directory as a public entry point, nested resource module, shared module, or helper/composition directory. Account for all inventory rows; explicitly mark non-resource helpers as not applicable rather than silently omitting them. Do not infer that nested modules are complete because their parent module is complete.

## Audit each module

1. Read the module and trace its public configuration end to end: root variable/type/validation, category locals, root aggregator inputs and `depends_on`, `remote_objects`, `combined_objects`, root outputs, examples, module documentation, relevant tests, and the repository's Terraform instructions.
2. Identify each directly managed resource and data source, its provider, and the provider version resolved or constrained by the root.
3. Search the exact provider and resource/data-source documentation for that version before proposing HCL changes. For AzureRM, follow Pattern 0 in [Azure schema validation](../azure-schema-validation/SKILL.md). For AzAPI, also verify the ARM resource type, API version, request body schema, exported response shape, and timeouts.
4. Compare provider requirements against module configuration and implementation: required/optional/computed arguments, nested blocks, timeout operations, managed child resources, dependency references, diagnostics/private endpoints when supported, and useful resource outputs.
5. Record each item as implemented, missing and appropriate, not applicable, or intentionally excluded with a short reason. Do not add computed or read-only values as configuration, implement deprecated provider resources, or expose settings that cannot be passed through safely.
6. Check root wiring for behavioral parity: new settings must survive root input typing and validation; dependency changes must be passed through the aggregator; outputs intended for other modules must reach `combined_objects`; new child resources must be integrated into ordering and outputs.
7. Preserve existing settings, defaults, resource addresses, names, and dependency behavior. Add new options as optional with provider-compatible defaults. Keep module and root/example variable types and validations aligned.

## Implement and verify

- Update only confirmed capability gaps. Follow CAF naming, locals, `remote_objects`, provider source/version, and module output conventions.
- Update the example and existing documentation to demonstrate new user-facing settings. Reuse the shared mock runner; add a focused module contract only when it asserts behavior the shared plan does not cover.
- Validate provider schemas before modifying resource arguments. Run focused Terraform formatting/validation, the relevant example mock plan, and applicable contract tests. Treat mock plans as syntax/planning evidence, not proof of Azure service acceptance.
- Work in small, dependency-ordered GitHub stacked PR layers using `gh stack`; use `gh stack add` and `gh stack submit` rather than manually creating dependent PRs. Validate each layer before pushing/submitting, and do not merge without authorization.
- Do not run live apply or destroy operations unless explicitly requested and separately confirmed.

## Inventory script tests

```bash
python -m unittest discover \
  -s .github/skills/module-coverage-audit/scripts \
  -p 'test_*.py' \
  -v
```
