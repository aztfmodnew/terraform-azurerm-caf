mock_provider "azurerm" {
  source = "./tests/mock_data"
}

mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}

mock_provider "azuread" {
  source = "./tests/mock_data"
}

run "test_plan" {
  command = plan

}
