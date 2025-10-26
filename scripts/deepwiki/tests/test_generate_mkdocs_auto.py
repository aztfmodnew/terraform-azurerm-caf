import os
import tempfile
import unittest
from pathlib import Path
from typing import Any, Dict, List
import textwrap

from scripts.deepwiki import generate_mkdocs_auto as gma


class GenerateMkDocsAutoTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmpdir = tempfile.TemporaryDirectory()
        base = Path(self.tmpdir.name)

        modules_root = base / "modules"
        modules_root.mkdir(parents=True, exist_ok=True)

        for category, module in (("cat1", "module_a"), ("cat2", "module_b")):
            module_path = modules_root / category / module
            module_path.mkdir(parents=True, exist_ok=True)
            (module_path / "main.tf").write_text(
                "\n".join(
                    [
                        'resource "azurerm_resource_group" "example" {',
                        '  name     = "example"',
                        '  location = "westeurope"',
                        "}",
                    ]
                ),
                encoding="utf-8",
            )

            if category == "cat1":
                (module_path / "variables.tf").write_text(
                    textwrap.dedent(
                        """
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
                        """
                    ).strip()
                    + "\n",
                    encoding="utf-8",
                )

                (module_path / "outputs.tf").write_text(
                    textwrap.dedent(
                        """
                        output "example_output" {
                          description = "Example output"
                          value       = azurerm_resource_group.example.id
                          sensitive   = false
                        }
                        """
                    ).strip()
                    + "\n",
                    encoding="utf-8",
                )

        docs_root = base / "docs"
        (docs_root / "modules").mkdir(parents=True, exist_ok=True)
        (docs_root / "root").mkdir(parents=True, exist_ok=True)

        self.original_globals: Dict[str, Any] = {
            "REPO_ROOT": gma.REPO_ROOT,
            "MODULES_ROOT": gma.MODULES_ROOT,
            "DOCS_ROOT": gma.DOCS_ROOT,
            "DOCS_MODULES": gma.DOCS_MODULES,
            "DOCS_ROOT_AGG": gma.DOCS_ROOT_AGG,
        }

        gma.REPO_ROOT = str(base)
        gma.MODULES_ROOT = str(modules_root)
        gma.DOCS_ROOT = str(docs_root)
        gma.DOCS_MODULES = str(docs_root / "modules")
        gma.DOCS_ROOT_AGG = str(docs_root / "root")

    def tearDown(self) -> None:
        for name, value in self.original_globals.items():
            setattr(gma, name, value)
        self.tmpdir.cleanup()

    def test_generate_modules_docs_multiple_categories(self) -> None:
        nav_modules, processed = gma.generate_modules_docs()

        self.assertGreaterEqual(processed, 2)
        self.assertGreaterEqual(len(nav_modules), 2)
        self.assertIn("cat1", nav_modules)
        self.assertIn("cat2", nav_modules)

    def test_generate_mkdocs_yml_force_flag(self) -> None:
        nav_modules, _ = gma.generate_modules_docs()
        nav_root: List[Dict[str, str]] = []

        mkdocs_path = Path(gma.REPO_ROOT) / "mkdocs.yml"
        mkdocs_path.write_text("original", encoding="utf-8")

        gma.generate_mkdocs_yml(nav_modules, nav_root, force_nav=False)
        self.assertEqual(mkdocs_path.read_text(encoding="utf-8"), "original")

        gma.generate_mkdocs_yml(nav_modules, nav_root, force_nav=True)
        content = mkdocs_path.read_text(encoding="utf-8")
        self.assertIn("site_name: CAF DeepWiki", content)
        self.assertIn("- cat1:", content)

    def test_extract_dependencies_returns_real_edges(self) -> None:
        content = textwrap.dedent(
            """
            resource "azurerm_resource_group" "rg" {
              name     = "rg-name"
              location = "westeurope"
            }

            resource "azurerm_storage_account" "sa" {
              name                     = "storage"
              resource_group_name      = azurerm_resource_group.rg.name
              location                 = azurerm_resource_group.rg.location
              account_tier             = "Standard"
              account_replication_type = "LRS"
            }

            module "network" {
              source                = "./network"
              resource_group_id     = azurerm_resource_group.rg.id
              diagnostics_workspace = module.diag.id
            }

            module "diag" {
              source = "./diagnostics"
            }
            """
        )

        nodes, edges = gma.extract_dependencies_from_content(content)

        self.assertIn("azurerm_resource_group.rg", nodes)
        self.assertIn("azurerm_storage_account.sa", nodes)
        self.assertIn("module.network", nodes)
        self.assertIn("module.diag", nodes)

        self.assertIn(("azurerm_storage_account.sa", "azurerm_resource_group.rg"), edges)
        self.assertIn(("module.network", "azurerm_resource_group.rg"), edges)
        self.assertIn(("module.network", "module.diag"), edges)

    def test_extract_variables_parses_defaults(self) -> None:
        module_path = Path(gma.MODULES_ROOT) / "cat1" / "module_a"
        variables = gma.extract_variables(str(module_path))
        var_lookup = {var["name"]: var for var in variables}

        self.assertIn("required_input", var_lookup)
        self.assertEqual(var_lookup["required_input"]["required"], "yes")
        self.assertEqual(var_lookup["required_input"].get("default"), "")

        self.assertIn("optional_input", var_lookup)
        optional_var = var_lookup["optional_input"]
        self.assertEqual(optional_var["required"], "no")
        self.assertEqual(optional_var.get("default"), "{}")
        self.assertIn(
            "optional_input must not be empty",
            optional_var.get("validation", ""),
        )

    def test_extract_outputs_includes_metadata(self) -> None:
        module_path = Path(gma.MODULES_ROOT) / "cat1" / "module_a"
        outputs = gma.extract_outputs(str(module_path))
        output_lookup = {out["name"]: out for out in outputs}

        self.assertIn("example_output", output_lookup)
        example_out = output_lookup["example_output"]
        self.assertEqual(example_out.get("description"), "Example output")
        self.assertIn(
            "azurerm_resource_group.example.id",
            example_out.get("value", ""),
        )
        self.assertIn("false", example_out.get("sensitive", ""))


if __name__ == "__main__":  # pragma: no cover
    unittest.main()
