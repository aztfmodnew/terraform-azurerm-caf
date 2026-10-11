import csv
import io
import tempfile
import unittest
from pathlib import Path

from inventory import collect_inventory, preserve_progress, write_inventory


class InventoryTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.repository_root = Path(self.temporary_directory.name)
        self.modules_root = self.repository_root / "modules"
        self.modules_root.mkdir()

    def tearDown(self):
        self.temporary_directory.cleanup()

    def write_terraform(self, relative_path: str, content: str) -> None:
        path = self.modules_root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def test_inventory_classifies_resources_data_sources_and_helpers(self):
        self.write_terraform(
            "storage/account/main.tf",
            """
# resource "azurerm_fake_resource" "ignored" {}
resource "azurerm_storage_account" "example" {}
data "azurerm_resource_group" "existing" {}
module "diagnostics" {
  source = "../../diagnostics"
}
""",
        )
        self.write_terraform(
            "storage/account/private_endpoint/main.tf",
            'resource "azurerm_private_endpoint" "example" {}\n',
        )
        self.write_terraform("diagnostics/main.tf", "locals { enabled = true }\n")
        (self.modules_root / "storage/account/.terraform/cache.tf").parent.mkdir(
            parents=True,
            exist_ok=True,
        )
        (self.modules_root / "storage/account/.terraform/cache.tf").write_text(
            'resource "ignored_cached_type" "example" {}\n',
            encoding="utf-8",
        )

        rows = collect_inventory(self.modules_root)
        rows_by_path = {row["path"]: row for row in rows}

        self.assertEqual(len(rows), 3)
        self.assertEqual(
            rows_by_path["modules/storage/account"]["classification"],
            "root-candidate",
        )
        self.assertEqual(
            rows_by_path["modules/storage/account"]["terraform_role"],
            "resource-bearing",
        )
        self.assertEqual(
            rows_by_path["modules/storage/account"]["provider_families"],
            "azurerm",
        )
        self.assertEqual(
            rows_by_path["modules/storage/account"]["managed_resource_types"],
            "azurerm_storage_account",
        )
        self.assertEqual(
            rows_by_path["modules/storage/account"]["data_source_types"],
            "azurerm_resource_group",
        )
        self.assertEqual(
            rows_by_path["modules/storage/account"]["child_module_calls"],
            "diagnostics",
        )
        self.assertEqual(
            rows_by_path["modules/storage/account/private_endpoint"]["classification"],
            "nested-candidate",
        )
        self.assertEqual(
            rows_by_path["modules/diagnostics"]["classification"],
            "shared-candidate",
        )
        self.assertEqual(
            rows_by_path["modules/diagnostics"]["terraform_role"],
            "composition-or-helper",
        )

    def test_inventory_serializes_a_tab_delimited_header_and_rows(self):
        self.write_terraform("security/keyvault/main.tf", "")
        output = io.StringIO()

        write_inventory(collect_inventory(self.modules_root), output)

        rows = list(csv.DictReader(io.StringIO(output.getvalue()), delimiter="\t"))
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["path"], "modules/security/keyvault")
        self.assertEqual(rows[0]["classification"], "root-candidate")
        self.assertEqual(rows[0]["audit_status"], "pending")

    def test_inventory_regeneration_preserves_review_progress_by_path(self):
        self.write_terraform("security/keyvault/main.tf", "")
        existing = io.StringIO(
            "path\taudit_status\tgap_decision\timplementation_status\ttest_status\tstack_pr\n"
            "modules/security/keyvault\tcomplete\tno-gap\tcomplete\tpassed\t#214\n"
        )

        rows = preserve_progress(collect_inventory(self.modules_root), existing)

        self.assertEqual(rows[0]["audit_status"], "complete")
        self.assertEqual(rows[0]["gap_decision"], "no-gap")
        self.assertEqual(rows[0]["implementation_status"], "complete")
        self.assertEqual(rows[0]["test_status"], "passed")
        self.assertEqual(rows[0]["stack_pr"], "#214")


if __name__ == "__main__":
    unittest.main()
