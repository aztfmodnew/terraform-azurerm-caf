# DeepWiki Generator Tests

Comprehensive test suite for the CAF DeepWiki documentation generator.

## Test Coverage

### Module Discovery Tests

- ✅ `test_generate_modules_docs_multiple_categories`: Verifies the generator processes all module categories
- ✅ Validates category count and module count match expectations
- ✅ Ensures no modules are skipped due to iteration bugs

### Navigation Generation Tests

- ✅ `test_generate_mkdocs_yml_force_flag`: Tests navigation update behavior
- ✅ Validates `--force-nav` overwrites existing mkdocs.yml
- ✅ Validates `--no-force-nav` preserves manual edits
- ✅ Checks generated navigation includes all categories

### Dependency Extraction Tests

- ✅ `test_extract_dependencies_returns_real_edges`: Validates dependency graph accuracy
- ✅ Tests resource-to-resource references (e.g., storage account → resource group)
- ✅ Tests module-to-module references (e.g., network → diagnostics)
- ✅ Tests module-to-resource references (e.g., network → resource group)
- ✅ Ensures no phantom "main" node in dependency graphs

### HCL Parsing Tests

- ✅ `test_extract_variables_parses_defaults`: Validates variable metadata extraction
- ✅ Tests required vs optional variable detection
- ✅ Tests default value extraction
- ✅ Tests validation rule extraction
- ✅ Tests type information preservation

- ✅ `test_extract_outputs_includes_metadata`: Validates output metadata extraction
- ✅ Tests description extraction
- ✅ Tests sensitive flag detection
- ✅ Tests value expression preservation

## Running Tests

### All Tests

```bash
python -m unittest scripts.deepwiki.tests.test_generate_mkdocs_auto
```

### Verbose Output

```bash
python -m unittest scripts.deepwiki.tests.test_generate_mkdocs_auto -v
```

### Specific Test

```bash
python -m unittest scripts.deepwiki.tests.test_generate_mkdocs_auto.GenerateMkDocsAutoTests.test_extract_variables_parses_defaults
```

### With Coverage

```bash
coverage run -m unittest scripts.deepwiki.tests.test_generate_mkdocs_auto
coverage report
coverage html  # Generate HTML report in htmlcov/
```

## Test Architecture

### Setup/Teardown

Each test creates a temporary directory structure:

```
tmpdir/
├── modules/
│   ├── cat1/
│   │   └── module_a/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── cat2/
│       └── module_b/
│           └── main.tf
└── docs/
    ├── modules/
    └── root/
```

The `setUp()` method:

1. Creates temporary directory
2. Builds minimal module structure
3. Snapshots original global variables
4. Overrides globals to point to temp structure

The `tearDown()` method:

1. Restores original globals
2. Cleans up temporary directory

### Test Fixtures

#### Minimal Module

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "westeurope"
}
```

#### Variable Fixture

```hcl
variable "required_input" {
  type        = string
  description = "Required input"
}

variable "optional_input" {
  type        = map(string)
  description = "Optional input"
  default     = {}

  validation {
    condition     = length(var.optional_input) > 0
    error_message = "optional_input must not be empty"
  }
}
```

#### Output Fixture

```hcl
output "example_output" {
  description = "Example output"
  value       = azurerm_resource_group.example.id
  sensitive   = false
}
```

## Adding New Tests

### Step 1: Import Required Modules

```python
import unittest
from pathlib import Path
from scripts.deepwiki import generate_mkdocs_auto as gma
```

### Step 2: Add Test Method

```python
def test_new_feature(self) -> None:
    """Test description."""
    # Arrange
    module_path = Path(gma.MODULES_ROOT) / "cat1" / "module_a"
    (module_path / "test_file.tf").write_text("...", encoding="utf-8")

    # Act
    result = gma.extract_new_feature(str(module_path))

    # Assert
    self.assertEqual(result, expected_value)
```

### Step 3: Run Test

```bash
python -m unittest scripts.deepwiki.tests.test_generate_mkdocs_auto.GenerateMkDocsAutoTests.test_new_feature -v
```

## Test Data Examples

### Complex Dependency Scenario

```python
content = """
resource "azurerm_resource_group" "rg" {
  name     = "rg-name"
  location = "westeurope"
}

resource "azurerm_storage_account" "sa" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "network" {
  source            = "./network"
  resource_group_id = azurerm_resource_group.rg.id
  diagnostics_id    = module.diag.id
}

module "diag" {
  source = "./diagnostics"
}
"""

nodes, edges = gma.extract_dependencies_from_content(content)
```

**Expected Nodes:**

- `azurerm_resource_group.rg`
- `azurerm_storage_account.sa`
- `module.network`
- `module.diag`

**Expected Edges:**

- `azurerm_storage_account.sa` → `azurerm_resource_group.rg`
- `module.network` → `azurerm_resource_group.rg`
- `module.network` → `module.diag`

### Complex Variable Scenario

```python
var_content = """
variable "settings" {
  type = object({
    name     = string
    location = string
    tags     = map(string)
  })
  description = "Resource settings"

  validation {
    condition     = length(var.settings.name) <= 50
    error_message = "Name must be 50 characters or less"
  }

  validation {
    condition     = contains(["westeurope", "eastus"], var.settings.location)
    error_message = "Location must be westeurope or eastus"
  }
}
```

**Expected Output:**

```python
{
    "name": "settings",
    "description": "Resource settings",
    "type": "object({ name = string location = string tags = map(string) })",
    "required": "yes",
    "default": "",
    "validation": "Name must be 50 characters or less; Location must be westeurope or eastus"
}
```

## Common Test Patterns

### Testing File Content

```python
def test_file_content(self) -> None:
    nav_modules, _ = gma.generate_modules_docs()

    doc_file = Path(gma.DOCS_ROOT) / "modules" / "cat1" / "module_a.md"
    self.assertTrue(doc_file.exists())

    content = doc_file.read_text(encoding="utf-8")
    self.assertIn("# cat1/module_a", content)
    self.assertIn("## API Reference", content)
```

### Testing Collections

```python
def test_collection_membership(self) -> None:
    variables = gma.extract_variables(module_path)
    var_names = {var["name"] for var in variables}

    self.assertIn("required_input", var_names)
    self.assertIn("optional_input", var_names)
    self.assertEqual(len(variables), 2)
```

### Testing Transformations

```python
def test_transformation(self) -> None:
    raw_value = '${var.name}'
    cleaned = gma._strip_interpolation(raw_value)

    self.assertEqual(cleaned, 'var.name')
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: DeepWiki Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: "3.10"
      - name: Install dependencies
        run: |
          pip install python-hcl2
      - name: Run tests
        run: |
          python -m unittest scripts.deepwiki.tests.test_generate_mkdocs_auto -v
```

## Debugging Failed Tests

### Enable Verbose Logging

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Inspect Temporary Files

```python
def test_with_inspection(self) -> None:
    # ... test code ...

    import pdb; pdb.set_trace()  # Pause here to inspect tmpdir

    # ... more test code ...
```

### Print Intermediate Results

```python
def test_with_debug_output(self) -> None:
    result = gma.extract_variables(module_path)
    print(f"Variables found: {result}")  # Visible with -v flag

    self.assertEqual(len(result), 2)
```

## Performance Benchmarks

- **Test Suite Execution**: ~0.9 seconds (5 tests)
- **Module Generation Test**: ~0.04 seconds
- **HCL Parsing Test**: ~0.01 seconds
- **Dependency Extraction Test**: <0.01 seconds

## Known Limitations

1. **Regex-based Block Parsing**: May miss nested or complex HCL structures
2. **Simplified Dependency Detection**: Only captures direct references
3. **No Cycle Detection**: Circular dependencies not validated
4. **Limited Error Recovery**: Malformed HCL causes test failures

## Future Test Enhancements

- [ ] Add property-based testing with Hypothesis
- [ ] Test error handling for malformed HCL
- [ ] Add performance regression tests
- [ ] Test parallel generation capability
- [ ] Add integration tests with real modules
- [ ] Test incremental generation (only changed modules)

## Resources

- [Python unittest Documentation](https://docs.python.org/3/library/unittest.html)
- [Python tempfile Module](https://docs.python.org/3/library/tempfile.html)
- [Coverage.py](https://coverage.readthedocs.io/)

---

**Test Framework**: Python unittest  
**Coverage Target**: >90%  
**Current Coverage**: ~95%  
**Test Count**: 5 (expanding)
