# Basic azurecaf naming example
ai_services = {
  example_azurecaf = {
    resource_group_key = "test-rg"
    name               = "example"
    sku_name           = "S1"

    tags = {
      purpose = "azurecaf-naming-demo"
    }
  }
}
