mock_provider "azurerm" {
  source = "./tests/mock_data"

  mock_resource "azurerm_resource_group_template_deployment" {
    defaults = {
      output_content = "{\"id\":{\"type\":\"String\",\"value\":\"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Web/hostingEnvironments/mock-ase\"},\"objectId\":{\"type\":\"String\",\"value\":\"00000000-0000-0000-0000-000000000001\"}}"
    }
  }
}

mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}

mock_provider "azuread" {
  source = "./tests/mock_data"
}

mock_provider "azapi" {
  source = "./tests/mock_data"
}

mock_provider "external" {
  source = "./tests/mock_data"
}

run "test_plan" {
  command = plan

}
