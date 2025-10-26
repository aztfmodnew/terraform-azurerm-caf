import unittest
from scripts.deepwiki import generate_mkdocs_auto as gma


class RootDependencyMapTests(unittest.TestCase):
    def test_parse_dot_module_edges_basic(self):
        dot = """
        digraph G {
          "module.a.azurerm_storage_account.sa" -> "module.b.azurerm_resource_group.rg";
          "azurerm_key_vault.kv" -> "module.a.azurerm_storage_account.sa";
        }
        """
        modules, edges = gma.parse_dot_module_edges(dot)
        self.assertIn("module.a", modules)
        self.assertIn("module.b", modules)
        self.assertIn("root", modules)
        self.assertIn(("module.a", "module.b"), edges)
        self.assertIn(("root", "module.a"), edges)


if __name__ == "__main__":  # pragma: no cover
    unittest.main()
