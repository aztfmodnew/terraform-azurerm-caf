# CAF Module Structure Guidelines

## Directory Structure

All modules MUST follow this standardized structure:

```
modules/
├── category_name/          # Category directory (e.g., monitoring, networking, compute)
│   └── module_name/        # Module directory
│       ├── providers.tf    # Provider requirements
│       ├── variables.tf    # Standard variables
│       ├── outputs.tf      # Module outputs
│       ├── locals.tf       # Local transformations (MANDATORY)
│       ├── azurecaf_name.tf # CAF naming (if resource has a name)
│       ├── module_name.tf  # Main resource definition
│       ├── diagnostics.tf  # Diagnostics integration (MANDATORY if supported)
│       ├── private_endpoints.tf # Private endpoint integration (MANDATORY if supported)
│       └── submodule/      # Submodule for child resources (if needed)
│           ├── providers.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── submodule.tf
└── shared_modules/         # Shared utility modules
    ├── diagnostics/        # Diagnostics configuration
    └── networking/
        └── private_endpoint/ # Private endpoint creation
```

## ⚠️ CRITICAL: Relative Path References

When creating or moving modules, **ALWAYS** update relative path references to shared modules:

### Standard Relative Paths (from `modules/category/module_name/`)

```hcl
# Diagnostics module reference
module "diagnostics" {
  source = "../../diagnostics"  # Points to modules/diagnostics/
  # ...
}

# Private endpoint module reference
module "private_endpoint" {
  source = "../../networking/private_endpoint"  # Points to modules/networking/private_endpoint/
  # ...
}
```

### Path Validation Checklist

When moving or creating a module:

- [ ] **Diagnostics path**: Verify `../../diagnostics` resolves to `modules/diagnostics/`
- [ ] **Private endpoint path**: Verify `../../networking/private_endpoint` resolves to `modules/networking/private_endpoint/`
- [ ] **Custom submodules**: Update paths to reflect new depth (e.g., `./submodule` or `../shared`)

### Testing Relative Paths

From the module directory, run:

```bash
# Test diagnostics path
realpath ../../diagnostics
# Expected: /path/to/repo/modules/diagnostics

# Test private_endpoint path
realpath ../../networking/private_endpoint
# Expected: /path/to/repo/modules/networking/private_endpoint
```

## Module Migration Checklist

When moving a module from `modules/module_name/` to `modules/category/module_name/`:

1. **Move the module directory**

   ```bash
   mv modules/module_name modules/category/module_name
   ```

2. **Update root aggregator file** (e.g., `grafana.tf`)

   ```diff
   - source = "./modules/module_name"
   + source = "./modules/category/module_name"
   ```

3. **Verify relative paths** in the moved module:
   - `diagnostics.tf` - should reference `../../diagnostics`
   - `private_endpoints.tf` - should reference `../../networking/private_endpoint`

4. **Regenerate documentation**

   ```bash
   python3 scripts/deepwiki/generate_mkdocs_auto.py --no-force-nav
   ```

5. **Test the module**

   ```bash
   cd examples/category/module_name/
   terraform init
   terraform validate
   ```

6. **Commit with descriptive message**

   ```bash
   git add -A
   git commit -m "refactor: move module_name to category/module_name

   - Updated source path in root aggregator
   - Verified relative path references
   - Regenerated documentation"
   ```

## Common Mistakes to Avoid

### ❌ Wrong: Module at root level

```
modules/
└── grafana/  # Missing category
```

### ✅ Correct: Module in category

```
modules/
└── monitoring/
    └── grafana/
```

### ❌ Wrong: Incorrect relative path after moving

```hcl
# In modules/monitoring/grafana/diagnostics.tf
module "diagnostics" {
  source = "../diagnostics"  # This would point to modules/monitoring/diagnostics (wrong!)
}
```

### ✅ Correct: Updated relative path

```hcl
# In modules/monitoring/grafana/diagnostics.tf
module "diagnostics" {
  source = "../../diagnostics"  # Points to modules/diagnostics/ (correct!)
}
```

## Automated Checks

The documentation generator (`scripts/deepwiki/generate_mkdocs_auto.py`) expects:

- Modules at depth 2: `modules/category/module_name/`
- Modules at depth 1 will NOT be processed
- Total processed modules should match the actual count

If a module is not appearing in the documentation, verify:

1. Is it in a category directory?
2. Does it have at least one `.tf` file?
3. Are the relative paths correct?

## Reference Examples

Good examples of correctly structured modules:

- `modules/monitoring/grafana/` - Diagnostics + Private Endpoints
- `modules/cognitive_services/ai_services/` - Complex with multiple dependencies
- `modules/networking/network_manager/` - With submodules

---

**Last updated**: October 26, 2025
**Maintainer**: CAF Terraform Team
